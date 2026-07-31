#!/usr/bin/env bash
# =============================================================================
# CIRCEE-LIFE Coupling
# =============================================================================
# Phase 1:  calibrate T0 modifiers so Y2020 group shares match propensity targets.
#           Sharing and sufficiency modifiers are
#           jointly tuned at year 2020 until both groups simultaneously match
#           their propensity-space targets. Order of tuning alternates each
#           iteration to mitigate ordering bias.
#
# Phase 2:  iterate CIRCEE <-> LIFE until lifestyle frequency trajectories stabilise
#             Run A (once): CIRCEE with all modifiers = 0 (universal baseline)
#             Run B (each iter): CIRCEE with full modifier path
#             LIFE step 3: freq_out_h(T) = freq_in_h(T) * (ES_h(T)/ES_h(T-1))
#             LIFE steps 4-6: Beh -> Cog -> dBeh -> new freq trajectory
#           Iterate until frequencies stabilise.
# =============================================================================


# -----------------------------------------------------------------------------
# Activate scenario-specific calibration ratios and frequency arrays
# (skipped in baseline mode — those values are unused there)
# -----------------------------------------------------------------------------
if [ "${RUN_MODE:-coupled}" == "coupled" ]; then
    SH_SCEN=$(echo "$SCENARIO_SHARING"     | tr '[:lower:]' '[:upper:]')
    EX_SCEN=$(echo "$SCENARIO_SUFFICIENCY" | tr '[:lower:]' '[:upper:]')
    SCENARIO_NAME="${SCENARIO_SHARING}_${SCENARIO_SUFFICIENCY}"

    for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do
        eval CALIB_RATIO_SHARING_${grp}=\$CALIB_RATIO_SHARING_${SH_SCEN}_${grp}
        eval CALIB_RATIO_EXP_${grp}=\$CALIB_RATIO_EXP_${EX_SCEN}_${grp}
    done

    for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do
        eval "FREQ_SHARING_${grp}=(\"\${FREQ_SHARING_${SH_SCEN}_${grp}[@]}\")"
        eval "FREQ_EXP_${grp}=(\"\${FREQ_EXP_${EX_SCEN}_${grp}[@]}\")"
    done

    convergence_log="${RESULTS_DIR}/convergence_${SCENARIO_NAME}.csv"
    life_state_file="${RESULTS_DIR}/life_dynamics_${SCENARIO_NAME}.csv"

    cat > "$convergence_log" <<< 'outer_iter;max_freq_sharing_change;max_freq_exp_change'
    cat > "$life_state_file" <<< 'outer_iter;year;freq_sharing_univ;freq_sharing_lc;freq_sharing_co;freq_sharing_ca;freq_exp_univ;freq_exp_lc;freq_exp_co;freq_exp_ca'

    OUTER_ITER=0
fi


# -----------------------------------------------------------------------------
# Precompute α trajectories (cognition & behaviour growth) from 2020 anchors
# -----------------------------------------------------------------------------
precompute_alpha() {
    local grp=$1 type=$2
    eval local prev=\$ALPHA_${type}_${grp}_2020
    eval local growth=\$ALPHA_${type}_GROWTH
    eval ALPHA_${type}_${grp}_2020=$prev
    for year in 2025 2030 2035 2040 2045 2050 2055 2060; do
        local next=$(echo "scale=15; $prev * (1 + $growth)" | bc)
        eval ALPHA_${type}_${grp}_${year}=$next
        prev=$next
    done
}


# -----------------------------------------------------------------------------
# Initialise frequency arrays at annual resolution: 5-year anchors at
# 2020,2025,...,2060; plateau 2061-2100; linear interpolation in between.
# -----------------------------------------------------------------------------
interpolate_and_set() {
    local behavior=$1 
    local steps=(2020 2025 2030 2035 2040 2045 2050 2055 2060)

    for i in "${!steps[@]}"; do
        local yr=${steps[$i]}
        for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do
            eval local val=\${FREQ_${behavior}_${grp}[$i]}
            eval FREQ_${behavior}_${grp}_${yr}=$val
        done
    done

    for yr in $(seq 2061 2100); do
        for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do
            eval local v=\$FREQ_${behavior}_${grp}_2060
            eval FREQ_${behavior}_${grp}_${yr}=$v
        done
    done

    local py=(2020 2025 2030 2035 2040 2045 2050 2055)
    local ny=(2025 2030 2035 2040 2045 2050 2055 2060)
    for s in "${!py[@]}"; do
        local y0=${py[$s]} y1=${ny[$s]}
        for yr in $(seq $(($y0+1)) $(($y1-1))); do
            local frac=$(echo "scale=10; ($yr-$y0)/($y1-$y0)" | bc)
            for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do
                eval local v0=\$FREQ_${behavior}_${grp}_${y0}
                eval local v1=\$FREQ_${behavior}_${grp}_${y1}
                eval FREQ_${behavior}_${grp}_${yr}=$(echo "scale=10; $v0+$frac*($v1-$v0)" | bc)
            done
        done
    done
}


# -----------------------------------------------------------------------------
# LIFE dynamics update (Steps 3-6)
# -----------------------------------------------------------------------------
update_life_dynamics() {
    echo ""
    echo "--- LIFE dynamics update [outer=${OUTER_ITER}] ---"

    local prev_year=2020

    for year in 2025 2030 2035 2040 2045 2050 2055 2060; do
        for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do

            # --- SHARING -----------------------------------------------------
            if [ "$grp" == "UNIVERSAL" ]; then
                eval local es_sh_curr=\$ES_SH_BASE_UNIVERSAL_${year}
                eval local es_sh_prev=\$ES_SH_BASE_UNIVERSAL_${prev_year}
            else
                eval local es_sh_curr=\$ES_SH_${grp}_${year}
                eval local es_sh_prev=\$ES_SH_${grp}_${prev_year}
            fi
            eval local freq_sh_in=\$FREQ_SHARING_${grp}_${year}
            eval local cr_sh=\$CALIB_RATIO_SHARING_${grp}

            if (( $(echo "$es_sh_prev == 0" | bc -l) )); then
                local new_freq_sh=$freq_sh_in
            else
                local out_freq_sh=$(echo "scale=10; $freq_sh_in * ($es_sh_curr / $es_sh_prev)" | bc)
                local beh_sh=$(echo "scale=10; $out_freq_sh / $cr_sh" | bc)
                eval local a_cog=\$ALPHA_COG_${grp}_${year}
                eval local b_cog=\$BETA_COG_${grp}
                local cog=$(echo "scale=10; $a_cog + $b_cog * $beh_sh" | bc)
                eval local a_beh=\$ALPHA_BEH_${grp}_${year}
                eval local b_beh=\$BETA_BEH_${grp}
                local dbeh=$(echo "scale=10; $a_beh + $b_beh * $cog" | bc)
                local new_freq_sh=$(echo "scale=10; $dbeh * $cr_sh" | bc)
            fi
            eval OLD_FREQ_SHARING_${grp}_${year}=\$FREQ_SHARING_${grp}_${year}
            eval FREQ_SHARING_${grp}_${year}=$new_freq_sh

            # --- SUFFICIENCY -------------------------------------------------
            if [ "$grp" == "UNIVERSAL" ]; then
                eval local es_ex_curr=\$ES_EXP_BASE_UNIVERSAL_${year}
                eval local es_ex_prev=\$ES_EXP_BASE_UNIVERSAL_${prev_year}
            else
                eval local es_ex_curr=\$ES_EXP_${grp}_${year}
                eval local es_ex_prev=\$ES_EXP_${grp}_${prev_year}
            fi
            eval local freq_ex_in=\$FREQ_EXP_${grp}_${year}
            eval local cr_ex=\$CALIB_RATIO_EXP_${grp}

            if (( $(echo "$es_ex_prev == 0" | bc -l) )); then
                local new_freq_ex=$freq_ex_in
            else
                local out_freq_ex=$(echo "scale=10; $freq_ex_in * ($es_ex_curr / $es_ex_prev)" | bc)
                local beh_ex=$(echo "scale=10; $out_freq_ex / $cr_ex" | bc)
                eval local a_cog=\$ALPHA_COG_${grp}_${year}
                eval local b_cog=\$BETA_COG_${grp}
                local cog=$(echo "scale=10; $a_cog + $b_cog * $beh_ex" | bc)
                eval local a_beh=\$ALPHA_BEH_${grp}_${year}
                eval local b_beh=\$BETA_BEH_${grp}
                local dbeh=$(echo "scale=10; $a_beh + $b_beh * $cog" | bc)
                local new_freq_ex=$(echo "scale=10; $dbeh * $cr_ex" | bc)
            fi
            eval OLD_FREQ_EXP_${grp}_${year}=\$FREQ_EXP_${grp}_${year}
            eval FREQ_EXP_${grp}_${year}=$new_freq_ex
        done

        eval local _sh_univ=\$FREQ_SHARING_UNIVERSAL_${year}
        eval local _sh_lc=\$FREQ_SHARING_LOWCARBON_${year}
        eval local _sh_co=\$FREQ_SHARING_CONSTRAINED_${year}
        eval local _sh_ca=\$FREQ_SHARING_CAUTIOUS_${year}
        eval local _ex_univ=\$FREQ_EXP_UNIVERSAL_${year}
        eval local _ex_lc=\$FREQ_EXP_LOWCARBON_${year}
        eval local _ex_co=\$FREQ_EXP_CONSTRAINED_${year}
        eval local _ex_ca=\$FREQ_EXP_CAUTIOUS_${year}
        echo "${OUTER_ITER};${year};${_sh_univ};${_sh_lc};${_sh_co};${_sh_ca};${_ex_univ};${_ex_lc};${_ex_co};${_ex_ca}" >> "$life_state_file"

        prev_year=$year
    done

    for yr in $(seq 2061 2100); do
        for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do
            eval FREQ_SHARING_${grp}_${yr}=\$FREQ_SHARING_${grp}_2060
            eval FREQ_EXP_${grp}_${yr}=\$FREQ_EXP_${grp}_2060
        done
    done

    local py=(2020 2025 2030 2035 2040 2045 2050 2055)
    local ny=(2025 2030 2035 2040 2045 2050 2055 2060)
    for s in "${!py[@]}"; do
        local y0=${py[$s]} y1=${ny[$s]}
        for yr in $(seq $(($y0+1)) $(($y1-1))); do
            local frac=$(echo "scale=10; ($yr-$y0)/($y1-$y0)" | bc)
            for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do
                eval local sv0=\$FREQ_SHARING_${grp}_${y0}
                eval local sv1=\$FREQ_SHARING_${grp}_${y1}
                eval FREQ_SHARING_${grp}_${yr}=$(echo "scale=10; $sv0+$frac*($sv1-$sv0)" | bc)
                eval local ev0=\$FREQ_EXP_${grp}_${y0}
                eval local ev1=\$FREQ_EXP_${grp}_${y1}
                eval FREQ_EXP_${grp}_${yr}=$(echo "scale=10; $ev0+$frac*($ev1-$ev0)" | bc)
            done
        done
    done

    echo "LIFE dynamics update complete."
}


# -----------------------------------------------------------------------------
# Outer convergence check
# -----------------------------------------------------------------------------
check_convergence() {
    local tol=$1
    local max_sh=0 max_ex=0

    for year in 2025 2030 2035 2040 2045 2050 2055 2060; do
        for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do
            eval local new_sh=\$FREQ_SHARING_${grp}_${year}
            eval local old_sh=\$OLD_FREQ_SHARING_${grp}_${year}
            eval local new_ex=\$FREQ_EXP_${grp}_${year}
            eval local old_ex=\$OLD_FREQ_EXP_${grp}_${year}
            [ -z "$old_sh" ] && continue
            local csh=$(echo "scale=10; sqrt(($new_sh-$old_sh)^2)" | bc -l)
            local cex=$(echo "scale=10; sqrt(($new_ex-$old_ex)^2)" | bc -l)
            (( $(echo "$csh > $max_sh" | bc -l) )) && max_sh=$csh
            (( $(echo "$cex > $max_ex" | bc -l) )) && max_ex=$cex
        done
    done

    echo "${OUTER_ITER};${max_sh};${max_ex}" >> "$convergence_log"
    echo "Convergence [outer=${OUTER_ITER}]: max_sh=${max_sh} max_ex=${max_ex} (tol=${tol})"

    if (( $(echo "$max_sh < $tol && $max_ex < $tol" | bc -l) )); then
        echo ">>> CONVERGED at iteration ${OUTER_ITER} <<<"
        return 0
    fi
    return 1
}


# -----------------------------------------------------------------------------
# Phase 1 helpers: T0 targets and joint verification run
# -----------------------------------------------------------------------------
get_sharing_targets_T0() {
    local col=$(get_col_for_year 2020)
    local result=$(awk -F "\"*,\"*" -v c=$col '{print $c}' \
        "${PATH_GRID_POINT_DATA}Sharing.csv" \
        | sed 's/Y2020//g' | tr '\n' ';' | sed 's/;$//')
    sharing_baseline_lc=$(echo "$result" | cut -d';' -f3 | tr ',' '.')
    sharing_baseline_ca=$(echo "$result" | cut -d';' -f4 | tr ',' '.')
    sharing_baseline_co=$(echo "$result" | cut -d';' -f5 | tr ',' '.')
    local rl=$(echo "scale=15; ${FREQ_SHARING_LOWCARBON[0]}   / ${FREQ_SHARING_UNIVERSAL[0]}" | bc)
    local rc=$(echo "scale=15; ${FREQ_SHARING_CONSTRAINED[0]} / ${FREQ_SHARING_UNIVERSAL[0]}" | bc)
    local ra=$(echo "scale=15; ${FREQ_SHARING_CAUTIOUS[0]}    / ${FREQ_SHARING_UNIVERSAL[0]}" | bc)
    target_sharing_lc=$(echo "scale=10; $sharing_baseline_lc * $rl" | bc)
    target_sharing_co=$(echo "scale=10; $sharing_baseline_co * $rc" | bc)
    target_sharing_ca=$(echo "scale=10; $sharing_baseline_ca * $ra" | bc)
}

get_exp_targets_T0() {
    local col=$(get_col_for_year 2020)
    local result=$(awk -F "\"*,\"*" -v c=$col '{print $c}' \
        "${PATH_GRID_POINT_DATA}Lowering_Expenditures.csv" \
        | sed 's/Y2020//g' | tr '\n' ';' | sed 's/;$//')
    exp_baseline_lc=$(echo "$result" | cut -d';' -f3 | tr ',' '.')
    exp_baseline_ca=$(echo "$result" | cut -d';' -f4 | tr ',' '.')
    exp_baseline_co=$(echo "$result" | cut -d';' -f5 | tr ',' '.')
    local rl=$(echo "scale=15; ${FREQ_EXP_LOWCARBON[0]}   / ${FREQ_EXP_UNIVERSAL[0]}" | bc)
    local rc=$(echo "scale=15; ${FREQ_EXP_CONSTRAINED[0]} / ${FREQ_EXP_UNIVERSAL[0]}" | bc)
    local ra=$(echo "scale=15; ${FREQ_EXP_CAUTIOUS[0]}    / ${FREQ_EXP_UNIVERSAL[0]}" | bc)
    target_exp_lc=$(echo "scale=10; $exp_baseline_lc / $rl" | bc)
    target_exp_co=$(echo "scale=10; $exp_baseline_co / $rc" | bc)
    target_exp_ca=$(echo "scale=10; $exp_baseline_ca / $ra" | bc)
}

check_joint_verification() {
    local iter=$1
    echo "  --- Joint verification [calib_iter=${iter}] ---"

    grep -v "^modifier_sharing_\|^modifier_expenditures_\|^modifier_repair_" \
        "${PATH_TEMPLATES}shocks.csv" > "${PATH_GRID_POINT_DATA}shocks.csv"
    for grp in lowcarbon cautious constrained; do
        eval local ms=\$modifier_sharing_${grp}
        eval local me=\$modifier_exp_${grp}
        for yr in $(seq 2019 2100); do
            echo "modifier_sharing_${grp};JPN;${yr};${ms}"
            echo "modifier_expenditures_${grp};JPN;${yr};${me}"
            echo "modifier_repair_${grp};JPN;${yr};0"
        done
    done >> "${PATH_GRID_POINT_DATA}shocks.csv"

    local conv=$(run_matlab)
    [ "$conv" == "false" ] && echo "  WARNING: joint verification did not converge." >&2

    local col=$(get_col_for_year 2020)
    local r_sh=$(awk -F "\"*,\"*" -v c=$col '{print $c}' \
        "${PATH_GRID_POINT_DATA}Sharing.csv" \
        | sed 's/Y2020//g' | tr '\n' ';' | sed 's/;$//')
    local sh_lc=$(echo "$r_sh" | cut -d';' -f3 | tr ',' '.')
    local sh_ca=$(echo "$r_sh" | cut -d';' -f4 | tr ',' '.')
    local sh_co=$(echo "$r_sh" | cut -d';' -f5 | tr ',' '.')

    local r_ex=$(awk -F "\"*,\"*" -v c=$col '{print $c}' \
        "${PATH_GRID_POINT_DATA}Lowering_Expenditures.csv" \
        | sed 's/Y2020//g' | tr '\n' ';' | sed 's/;$//')
    local ex_lc=$(echo "$r_ex" | cut -d';' -f3 | tr ',' '.')
    local ex_ca=$(echo "$r_ex" | cut -d';' -f4 | tr ',' '.')
    local ex_co=$(echo "$r_ex" | cut -d';' -f5 | tr ',' '.')

    echo "  Sharing:      lc=${sh_lc} (tgt=${target_sharing_lc})"
    echo "                ca=${sh_ca} (tgt=${target_sharing_ca})"
    echo "                co=${sh_co} (tgt=${target_sharing_co})"
    echo "  Sufficiency:  lc=${ex_lc} (tgt=${target_exp_lc})"
    echo "                ca=${ex_ca} (tgt=${target_exp_ca})"
    echo "                co=${ex_co} (tgt=${target_exp_co})"

    JOINT_CONVERGED=true
    for pair in "sh_lc:target_sharing_lc" "sh_ca:target_sharing_ca" "sh_co:target_sharing_co" \
                "ex_lc:target_exp_lc"     "ex_ca:target_exp_ca"     "ex_co:target_exp_co"; do
        local vv=${pair%%:*} tv=${pair##*:}
        eval local val=\$$vv
        eval local tgt=\$$tv
        [ -z "$val" ] || [ -z "$tgt" ] || [ "$tgt" == "0" ] && continue
        local err=$(echo "scale=10; sqrt(($val-$tgt)^2)/$tgt" | bc -l)
        (( $(echo "$err > $CALIB_TOL" | bc -l) )) && JOINT_CONVERGED=false
    done

    [ "$JOINT_CONVERGED" == "true" ] && \
        echo "  >>> Joint calibration CONVERGED at iter ${iter} <<<" || \
        echo "  Not yet jointly converged."
}


# -----------------------------------------------------------------------------
# Phase 1 driver
# -----------------------------------------------------------------------------
phase1_joint_calibration() {
    banner "PHASE 1: Joint T0 Calibration (propensity-space)"
    echo "    Sharing:     ${SCENARIO_SHARING}"
    echo "    Sufficiency: ${SCENARIO_SUFFICIENCY}"

    modifier_sharing_lowcarbon=0
    modifier_sharing_cautious=0
    modifier_sharing_constrained=0
    modifier_exp_lowcarbon=0
    modifier_exp_cautious=0
    modifier_exp_constrained=0

    echo "--- Initial baseline run ---"
    rm -f "${PATH_GRID_POINT_DATA}Lowering_Expenditures.csv"
    rm -f "${PATH_GRID_POINT_DATA}Sharing.csv"       
    build_baseline_shocks_csv
    local conv=$(run_matlab)
    get_sharing_targets_T0
    get_exp_targets_T0

    echo "Sharing targets:     lc=${target_sharing_lc} ca=${target_sharing_ca} co=${target_sharing_co}"
    echo "Sufficiency targets: lc=${target_exp_lc} ca=${target_exp_ca} co=${target_exp_co}"

    JOINT_CONVERGED=false
    local calib_iter=0

    while [ "$JOINT_CONVERGED" == "false" ] && [ "$calib_iter" -lt "$MAX_CALIB_ITER" ]; do

        calib_iter=$((calib_iter + 1))
        echo ""
        echo "  ===== Joint calibration iteration ${calib_iter} ====="

        if (( calib_iter % 2 == 1 )); then
            echo "  Order: sufficiency -> sharing"
            _calibrate_sufficiency
            _calibrate_sharing
        else
            echo "  Order: sharing -> sufficiency"
            _calibrate_sharing
            _calibrate_sufficiency
        fi

        check_joint_verification $calib_iter
    done

    [ "$JOINT_CONVERGED" == "false" ] && \
        echo "WARNING: Joint calibration did not converge. Proceeding with best available modifiers."

    banner "Phase 1 complete"
    echo "  Sharing:     lc=${modifier_sharing_lowcarbon} ca=${modifier_sharing_cautious} co=${modifier_sharing_constrained}"
    echo "  Sufficiency: lc=${modifier_exp_lowcarbon} ca=${modifier_exp_cautious} co=${modifier_exp_constrained}"
}

_calibrate_sharing() {
    export FIXED_MOD_EXP_LOWCARBON=$modifier_exp_lowcarbon
    export FIXED_MOD_EXP_CAUTIOUS=$modifier_exp_cautious
    export FIXED_MOD_EXP_CONSTRAINED=$modifier_exp_constrained
    export LIFESTYLE_SCENARIO=$SCENARIO_SHARING
    rm -f results_final_sharing.csv
    bash lib/tune_sharing.sh
    read modifier_sharing_lowcarbon modifier_sharing_cautious modifier_sharing_constrained < <(
        tail -n1 "${RESULTS_DIR}/results_final_sharing.csv" | tr ';' ' ' | awk '{print $1, $2, $3}'
    )
    echo "  Sharing: lc=${modifier_sharing_lowcarbon} ca=${modifier_sharing_cautious} co=${modifier_sharing_constrained}"
}

_calibrate_sufficiency() {
    export FIXED_MOD_SH_LOWCARBON=$modifier_sharing_lowcarbon
    export FIXED_MOD_SH_CAUTIOUS=$modifier_sharing_cautious
    export FIXED_MOD_SH_CONSTRAINED=$modifier_sharing_constrained
    export LIFESTYLE_SCENARIO=$SCENARIO_SUFFICIENCY
    rm -f results_final_expenditures.csv
    bash lib/tune_expenditures.sh
    read modifier_exp_lowcarbon modifier_exp_cautious modifier_exp_constrained < <(
        tail -n1 "${RESULTS_DIR}/results_final_expenditures.csv" | tr ';' ' ' | awk '{print $1, $2, $3}'
    )
    echo "  Sufficiency: lc=${modifier_exp_lowcarbon} ca=${modifier_exp_cautious} co=${modifier_exp_constrained}"
}


# -----------------------------------------------------------------------------
# Phase 2 driver: outer CIRCEE <-> LIFE convergence loop
# -----------------------------------------------------------------------------
phase2_outer_loop() {
    banner "PHASE 2: OUTER CONVERGENCE LOOP"

    # Run A: baseline (all modifiers = 0). 
    echo "--- Run A: Baseline (all modifiers = 0) — one-time run ---"
    build_baseline_shocks_csv
    local conv=$(run_matlab)
    [ "$conv" == "false" ] && echo "WARNING: Baseline run did not converge." >&2
    cp "${PATH_GRID_POINT_DATA}Sharing.csv" \
       "${PATH_GRID_POINT_DATA}Sharing_baseline.csv"
    cp "${PATH_GRID_POINT_DATA}Lowering_Expenditures.csv" \
       "${PATH_GRID_POINT_DATA}Lowering_Expenditures_baseline.csv"
    read_circee_outputs "BASE"
    echo "Baseline run complete."

    OUTER_CONVERGED=false

    while [ "$OUTER_CONVERGED" == "false" ] && [ "$OUTER_ITER" -lt "$MAX_OUTER_ITERATIONS" ]; do

        OUTER_ITER=$((OUTER_ITER + 1))
        echo ""
        echo "################################################################"
        echo "### OUTER ITERATION ${OUTER_ITER} / ${MAX_OUTER_ITERATIONS}"
        echo "################################################################"

        echo "--- Run B: Full modifier path ---"
        build_shocks_csv \
            "$modifier_sharing_lowcarbon" "$modifier_sharing_cautious" "$modifier_sharing_constrained" \
            "$modifier_exp_lowcarbon"     "$modifier_exp_cautious"     "$modifier_exp_constrained"
        conv=$(run_matlab)
        [ "$conv" == "false" ] && echo "WARNING: Modifier run did not converge." >&2
        read_circee_outputs "MOD"
        echo "Modifier run complete."

        update_life_dynamics

        if check_convergence "$OUTER_TOL"; then
            OUTER_CONVERGED=true
        fi
    done
}


# -----------------------------------------------------------------------------
# Write converged modifier path and run CIRCEE once more
# -----------------------------------------------------------------------------
finalize() {
    if [ "$OUTER_CONVERGED" == "true" ]; then
        banner "CONVERGED after ${OUTER_ITER} outer iterations"
    else
        banner "WARNING: max iterations (${MAX_OUTER_ITERATIONS}) reached"
    fi

    echo "Writing final converged modifier path..."
    build_shocks_csv \
        "$modifier_sharing_lowcarbon" "$modifier_sharing_cautious" "$modifier_sharing_constrained" \
        "$modifier_exp_lowcarbon"     "$modifier_exp_cautious"     "$modifier_exp_constrained"

    echo "Running CIRCEE one last time with the converged modifier path..."
    local conv=$(run_matlab)
    [ "$conv" == "false" ] && echo "WARNING: Final CIRCEE run did not converge." >&2

    local tag="${SCENARIO_NAME}_${CIRCEE_SIGMA_SCENARIO}"
    cp "${PATH_GRID_POINT_DATA}Sharing.csv"               "${RESULTS_DIR}/Sharing_final_${tag}.csv"
    cp "${PATH_GRID_POINT_DATA}Lowering_Expenditures.csv" "${RESULTS_DIR}/Lowering_Expenditures_final_${tag}.csv"
    cp "${PATH_GRID_POINT_DATA}shocks.csv"                "${RESULTS_DIR}/shocks_final_${tag}.csv"

    banner "Output files"
    echo "  ${RESULTS_DIR}/shocks_final_${tag}.csv               — converged modifier path"
    echo "  ${RESULTS_DIR}/Sharing_final_${tag}.csv              — final CIRCEE sharing outputs"
    echo "  ${RESULTS_DIR}/Lowering_Expenditures_final_${tag}.csv — final CIRCEE expenditures outputs"
    echo "  ${convergence_log}                              — convergence history"
    echo "  ${life_state_file}                              — LIFE frequency state per iteration"
}


# -----------------------------------------------------------------------------
# Baseline mode — single CIRCEE run with all modifiers = 0. No Phase 1,
# no Phase 2, no LIFE coupling. Used when RUN_MODE="baseline".
# -----------------------------------------------------------------------------
run_baseline() {
    banner "CIRCEE baseline run (no lifestyles, no modifiers)"
    echo "  MATLAB binary: ${MATLAB_BIN}"
    echo ""

    build_baseline_shocks_csv
    local conv=$(run_matlab)
    [ "$conv" == "false" ] && echo "WARNING: CIRCEE did not converge." >&2

    cp "${PATH_GRID_POINT_DATA}Sharing.csv"              "${RESULTS_DIR}/Sharing_baseline.csv"
    cp "${PATH_GRID_POINT_DATA}Lowering_Expenditures.csv" "${RESULTS_DIR}/Lowering_Expenditures_baseline.csv"
    cp "${PATH_GRID_POINT_DATA}shocks.csv"               "${RESULTS_DIR}/shocks_baseline.csv"

    banner "Baseline run complete"
    echo "  ${RESULTS_DIR}/shocks_baseline.csv               — zero-modifier shocks fed to CIRCEE"
    echo "  ${RESULTS_DIR}/Sharing_baseline.csv              — CIRCEE sharing outputs"
    echo "  ${RESULTS_DIR}/Lowering_Expenditures_baseline.csv — CIRCEE expenditures outputs"
}


run_coupling() {
    mkdir -p "$PATH_GRID_POINT_DATA"

    if [ "${RUN_MODE:-coupled}" == "baseline" ]; then
        run_baseline
        return
    fi

    banner "CIRCEE-LIFE Full Iterative Coupling"
    echo "  Sharing scenario:     ${SCENARIO_SHARING}"
    echo "  Sufficiency scenario: ${SCENARIO_SUFFICIENCY}"
    echo "  Combined name:        ${SCENARIO_NAME}"
    echo "  MATLAB binary:        ${MATLAB_BIN}"

    for grp in UNIVERSAL LOWCARBON CONSTRAINED CAUTIOUS; do
        precompute_alpha $grp COG
        precompute_alpha $grp BEH
    done
    echo "α trajectories precomputed."

    interpolate_and_set SHARING
    interpolate_and_set EXP
    echo "Frequency arrays initialised."

    phase1_joint_calibration
    phase2_outer_loop
    finalize
}