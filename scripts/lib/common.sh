#!/usr/bin/env bash
# =============================================================================
# CIRCEE-LIFE — Shared helper functions
# =============================================================================
# Sourced by run.sh, lib/coupling.sh, and the tuners.
# Depends on variables defined in config.sh and lib/parameters.sh.
# =============================================================================

banner() {
    local msg="$1"
    echo ""
    echo "================================================================"
    echo "=== $msg"
    echo "================================================================"
}

# -----------------------------------------------------------------------------
# Validate user configuration.
# -----------------------------------------------------------------------------
validate_config() {
    case "${RUN_MODE:-coupled}" in
        coupled|baseline) ;;
        *)
            echo "ERROR: Unknown RUN_MODE '${RUN_MODE}'. Use: coupled | baseline" >&2
            exit 1
            ;;
    esac

    if [ "${RUN_MODE:-coupled}" == "coupled" ] && [ "${WELFARE_MODE}" != "sensitivity" ]; then
        for s in "$SCENARIO_SHARING" "$SCENARIO_SUFFICIENCY"; do
            if [ "$s" != "ecoactive" ] && [ "$s" != "affordability" ]; then
                echo "ERROR: Unknown scenario '${s}'. Use: ecoactive | affordability" >&2
                exit 1
            fi
        done
    fi
}

# -----------------------------------------------------------------------------
# Test that MATLAB is callable. Aborts on failure.
# -----------------------------------------------------------------------------
test_matlab() {
    if [ ! -x "$MATLAB_BIN" ] && ! command -v "$MATLAB_BIN" >/dev/null 2>&1; then
        echo "ERROR: MATLAB binary not found at: $MATLAB_BIN" >&2
        echo "       Edit MATLAB_BIN in config.sh." >&2
        exit 1
    fi

    mkdir -p ~/Documents/MATLAB
    cat > ~/Documents/MATLAB/startup.m <<EOL
com.mathworks.services.Prefs.setBooleanPref('WebBrowser', false);
EOL

    cat > minimal_test_script.m <<EOL
disp('Running minimal test script');
exit;
EOL

    echo "Running minimal MATLAB test script..."
    "$MATLAB_BIN" -nodisplay -nosplash -nodesktop \
        -r "minimal_test_script; exit;" > minimal_test_log.txt 2>&1

    if grep -q 'Running minimal test script' minimal_test_log.txt; then
        echo "MATLAB launches cleanly."
    else
        echo "ERROR: MATLAB test failed. See minimal_test_log.txt for details." >&2
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Single CIRCEE run. Echoes 'true' if Dynare found a perfect-foresight
# solution, 'false' otherwise.
# -----------------------------------------------------------------------------
run_matlab() {
    (
        cd "$SRC_DIR" && "$MATLAB_BIN" -nodisplay -nosplash -nodesktop \
        -r "try; CIRCEE_RunFile('calibration'); catch e; disp(e.message); end; exit;" \
        > "${RESULTS_DIR}/matlab_logs.txt" 2>&1
    ) 2>/dev/null || true
    grep -q 'Perfect foresight solution found.' "${RESULTS_DIR}/matlab_logs.txt" && echo "true" || echo "false"
}


# -----------------------------------------------------------------------------
# Column index in CIRCEE CSV outputs for a given calendar year.
# -----------------------------------------------------------------------------
get_col_for_year() {
    echo $(( ($1 - 2018) + 2 ))
}

# -----------------------------------------------------------------------------
# Build shocks.csv with all modifiers set to zero (baseline / universal run).
# -----------------------------------------------------------------------------
build_baseline_shocks_csv() {
    grep -v "^modifier_sharing_\|^modifier_expenditures_\|^modifier_repair_" \
        "${PATH_TEMPLATES}shocks.csv" > "${PATH_GRID_POINT_DATA}shocks.csv"

    for grp in lowcarbon cautious constrained; do
        for yr in $(seq 2019 2100); do
            echo "modifier_sharing_${grp};JPN;${yr};0"
            echo "modifier_expenditures_${grp};JPN;${yr};0"
            echo "modifier_repair_${grp};JPN;${yr};0"
        done
    done >> "${PATH_GRID_POINT_DATA}shocks.csv"
}

# -----------------------------------------------------------------------------
# Build shocks.csv with a full modifier path (sharing × sufficiency × group).
# Time-varying modifiers are obtained by rescaling T0 modifiers with the
# ratio between T0 and T frequency ratios (group / universal).
# -----------------------------------------------------------------------------
build_shocks_csv() {
    local mod_sh_lc=$1 mod_sh_ca=$2 mod_sh_co=$3
    local mod_ex_lc=$4 mod_ex_ca=$5 mod_ex_co=$6

    grep -v "^modifier_sharing_\|^modifier_expenditures_\|^modifier_repair_" \
        "${PATH_TEMPLATES}shocks.csv" > "${PATH_GRID_POINT_DATA}shocks.csv"

    for grp in lowcarbon cautious constrained; do
        for yr in $(seq 2019 2100); do
            echo "modifier_repair_${grp};JPN;${yr};0"
        done
    done >> "${PATH_GRID_POINT_DATA}shocks.csv"

    local LIFE_STEPS=(2020 2025 2030 2035 2040 2045 2050 2055 2060)

    for grp in lowcarbon cautious constrained; do
        local GRP=$(echo $grp | tr '[:lower:]' '[:upper:]')
        local short
        case $grp in
            lowcarbon)   short=lc ;;
            cautious)    short=ca ;;
            constrained) short=co ;;
        esac

        eval local m_sh=\$mod_sh_${short}
        eval local m_ex=\$mod_ex_${short}

        local mod_sh_steps=()
        local mod_ex_steps=()
        mod_sh_steps[0]=$m_sh
        mod_ex_steps[0]=$m_ex

        eval local freq_sh_prev=\$FREQ_SHARING_${GRP}_2020
        eval local freq_ex_prev=\$FREQ_EXP_${GRP}_2020

        for s in 1 2 3 4 5 6 7 8; do
            local step_yr=${LIFE_STEPS[$s]}
            eval local freq_sh_step=\$FREQ_SHARING_${GRP}_${step_yr}
            eval local freq_ex_step=\$FREQ_EXP_${GRP}_${step_yr}
            mod_sh_steps[$s]=$(echo "scale=10; (0${mod_sh_steps[$((s-1))]}) * (0$freq_sh_step) / (0$freq_sh_prev)" | bc)
            mod_ex_steps[$s]=$(echo "scale=10; (0${mod_ex_steps[$((s-1))]}) * (0$freq_ex_step) / (0$freq_ex_prev)" | bc)
            freq_sh_prev=$freq_sh_step
            freq_ex_prev=$freq_ex_step
        done

        echo "modifier_sharing_${grp};JPN;2019;${m_sh}"
        echo "modifier_expenditures_${grp};JPN;2019;${m_ex}"

        for s in 0 1 2 3 4 5 6 7; do
            local y0=${LIFE_STEPS[$s]}
            local y1=${LIFE_STEPS[$((s+1))]}
            local msh0=${mod_sh_steps[$s]}
            local msh1=${mod_sh_steps[$((s+1))]}
            local mex0=${mod_ex_steps[$s]}
            local mex1=${mod_ex_steps[$((s+1))]}

            for yr in $(seq $y0 $((y1-1))); do
                local frac=$(echo "scale=10; ($yr - $y0) / ($y1 - $y0)" | bc)
                local growth_sh=$(echo "scale=10; e($frac * l((0$msh1)/(0$msh0)))" | bc -l)
                local growth_ex=$(echo "scale=10; e($frac * l((0$mex1)/(0$mex0)))" | bc -l)
                local mod_sh_yr=$(echo "scale=10; (0$msh0) * $growth_sh" | bc)
                local mod_ex_yr=$(echo "scale=10; (0$mex0) * $growth_ex" | bc)
                echo "modifier_sharing_${grp};JPN;${yr};${mod_sh_yr}"
                echo "modifier_expenditures_${grp};JPN;${yr};${mod_ex_yr}"
            done
        done

        for yr in $(seq 2060 2100); do
            echo "modifier_sharing_${grp};JPN;${yr};${mod_sh_steps[8]}"
            echo "modifier_expenditures_${grp};JPN;${yr};${mod_ex_steps[8]}"
        done

    done >> "${PATH_GRID_POINT_DATA}shocks.csv"
}

# -----------------------------------------------------------------------------
# Read CIRCEE outputs (Sharing.csv, Lowering_Expenditures.csv) for each year
# in LIFE_STEPS. Stores results in env vars:
#   ES_SH_<GRP>_<YEAR>   ES_EXP_<GRP>_<YEAR>
#   (or ES_SH_BASE_UNIVERSAL_<YEAR> for the baseline run)
# -----------------------------------------------------------------------------
read_circee_outputs() {
    local prefix=$1 

    for yr in "${LIFE_STEPS[@]}"; do
        local col=$(get_col_for_year $yr)

        if [ "$prefix" == "BASE" ]; then
            local r_sh=$(awk -F "\"*,\"*" -v c=$col '{print $c}' \
                "${PATH_GRID_POINT_DATA}Sharing_baseline.csv" \
                | sed "s/Y${yr}//g" | tr '\n' ';' | sed 's/;$//')
            eval ES_SH_BASE_UNIVERSAL_${yr}=$(echo "$r_sh" | cut -d';' -f2 | tr ',' '.')

            local r_ex=$(awk -F "\"*,\"*" -v c=$col '{print $c}' \
                "${PATH_GRID_POINT_DATA}Lowering_Expenditures_baseline.csv" \
                | sed "s/Y${yr}//g" | tr '\n' ';' | sed 's/;$//')
            eval ES_EXP_BASE_UNIVERSAL_${yr}=$(echo "$r_ex" | cut -d';' -f2 | tr ',' '.')
        else
            local r_sh=$(awk -F "\"*,\"*" -v c=$col '{print $c}' \
                "${PATH_GRID_POINT_DATA}Sharing.csv" \
                | sed "s/Y${yr}//g" | tr '\n' ';' | sed 's/;$//')
            eval ES_SH_LOWCARBON_${yr}=$(echo "$r_sh" | cut -d';' -f3 | tr ',' '.')
            eval ES_SH_CAUTIOUS_${yr}=$(echo "$r_sh" | cut -d';' -f4 | tr ',' '.')
            eval ES_SH_CONSTRAINED_${yr}=$(echo "$r_sh" | cut -d';' -f5 | tr ',' '.')

            local r_ex=$(awk -F "\"*,\"*" -v c=$col '{print $c}' \
                "${PATH_GRID_POINT_DATA}Lowering_Expenditures.csv" \
                | sed "s/Y${yr}//g" | tr '\n' ';' | sed 's/;$//')
            eval ES_EXP_LOWCARBON_${yr}=$(echo "$r_ex" | cut -d';' -f3 | tr ',' '.')
            eval ES_EXP_CAUTIOUS_${yr}=$(echo "$r_ex" | cut -d';' -f4 | tr ',' '.')
            eval ES_EXP_CONSTRAINED_${yr}=$(echo "$r_ex" | cut -d';' -f5 | tr ',' '.')
        fi
    done
}
