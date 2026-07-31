#!/usr/bin/env bash
# =============================================================================
# CIRCEE-LIFE — Expenditures (sufficiency) modifier T0 calibration
# =============================================================================
# Calibrates modifier_expenditures_{lowcarbon,cautious,constrained} so that
# group-level Lowering_Expenditures at Y2020 matches propensity-space targets.
#
# Inputs :
#   LIFESTYLE_SCENARIO          ecoactive | affordability
#   FIXED_MOD_SH_LOWCARBON      sharing modifier held fixed (default 0)
#   FIXED_MOD_SH_CAUTIOUS
#   FIXED_MOD_SH_CONSTRAINED
#
# Outputs:
#   results_final_expenditures.csv   one row per bisection probe; last row = final
#   modifiers_expenditures_T0.csv    summary table (one row per group)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

source config.sh
source lib/parameters.sh
source lib/common.sh

# -----------------------------------------------------------------------------
# Scenario propensities -> ratios (group / universal)
# -----------------------------------------------------------------------------
SCEN=$(echo "${LIFESTYLE_SCENARIO:-ecoactive}" | tr '[:lower:]' '[:upper:]')

eval P_UNIV=\$PROP_SUFF_${SCEN}_UNIVERSAL
eval P_LC=\$PROP_SUFF_${SCEN}_LOWCARBON
eval P_CA=\$PROP_SUFF_${SCEN}_CAUTIOUS
eval P_CO=\$PROP_SUFF_${SCEN}_CONSTRAINED

echo "Sufficiency scenario: ${LIFESTYLE_SCENARIO:-ecoactive}"

RATIO_LOWCARBON=$(echo   "scale=15; $P_LC / $P_UNIV" | bc)
RATIO_CAUTIOUS=$(echo    "scale=15; $P_CA / $P_UNIV" | bc)
RATIO_CONSTRAINED=$(echo "scale=15; $P_CO / $P_UNIV" | bc)


data_template=$(cat "${PATH_TEMPLATES}shocks.csv")
tmp_result_file="${RESULTS_DIR}/result_file_expenditures.csv"
final_result_file="${RESULTS_DIR}/results_final_expenditures.csv"

cat > $tmp_result_file <<< 'modifier_expenditures_lowcarbon;modifier_expenditures_cautious;modifier_expenditures_constrained;expenditures_lowcarbon;expenditures_cautious;expenditures_constrained;converged'


# -----------------------------------------------------------------------------
# Write shocks.csv with current expenditures-modifier triplet. 
# Repair available in future versions
# -----------------------------------------------------------------------------
replace_templates() {
    local val_lc=$1 val_ca=$2 val_co=$3

    sed \
        -e "s/\%modifier_sharing_constrained\%/${FIXED_MOD_SH_CONSTRAINED:-0}/" \
        -e "s/\%modifier_sharing_cautious\%/${FIXED_MOD_SH_CAUTIOUS:-0}/" \
        -e "s/\%modifier_sharing_lowcarbon\%/${FIXED_MOD_SH_LOWCARBON:-0}/" \
        -e "s/\%modifier_repair_constrained\%/0/" \
        -e "s/\%modifier_repair_cautious\%/0/" \
        -e "s/\%modifier_repair_lowcarbon\%/0/" \
        -e "s/\%modifier_expenditures_constrained\%/${val_co}/" \
        -e "s/\%modifier_expenditures_cautious\%/${val_ca}/" \
        -e "s/\%modifier_expenditures_lowcarbon\%/${val_lc}/" \
        <<< "$data_template" > "${PATH_GRID_POINT_DATA}shocks.csv"
}

save_results() {
    local m_lc=$1 m_ca=$2 m_co=$3

    res_expenditures=$(awk -F "\"*,\"*" '{print $4}' "${PATH_GRID_POINT_DATA}Lowering_Expenditures.csv")
    result_to_add=$(echo "${res_expenditures}" | sed 's/Y2020//g' | tr '\n' ';' | sed 's/;$//')
    expenditures_lowcarbon=$(echo $result_to_add  | cut -d ';' -f 3 | tr ',' '.')
    expenditures_cautious=$(echo  $result_to_add  | cut -d ';' -f 4 | tr ',' '.')
    expenditures_constrained=$(echo $result_to_add| cut -d ';' -f 5 | tr ',' '.')

    echo "${m_lc};${m_ca};${m_co};${expenditures_lowcarbon};${expenditures_cautious};${expenditures_constrained};${last_run_is_valid}" \
        >> $tmp_result_file
}

compute_point() {
    local m_lc=$1 m_ca=$2 m_co=$3

    replace_templates "$m_lc" "$m_ca" "$m_co"

    (cd "$SRC_DIR" && \
    "$MATLAB_BIN" -nodisplay -nosplash -nodesktop \
    -r "try; CIRCEE_RunFile('calibration'); catch e; disp(e.message); end; exit;" \
    > "${RESULTS_DIR}/matlab_logs_calib.txt" 2>&1) 2>/dev/null || true

    if grep -q 'Perfect foresight solution found.' "${RESULTS_DIR}/matlab_logs_calib.txt"; then
        last_run_is_valid=true
    else
        last_run_is_valid=false
    fi

    save_results "$m_lc" "$m_ca" "$m_co"
}

# -----------------------------------------------------------------------------
# Bisection in one dimension at a time
# -----------------------------------------------------------------------------
bisection_expenditures() {
    local tol=$1 tuned=$2

    local low=-0.3 high=0.3
    local target mid val_mid error

    if   [ "$tuned" == "lowcarbon"   ]; then target=$target_lowcarbon
    elif [ "$tuned" == "cautious"    ]; then target=$target_cautious
    elif [ "$tuned" == "constrained" ]; then target=$target_constrained
    fi

    while true; do
        mid=$(echo "scale=10; ($low + $high) / 2" | bc)

        if   [ "$tuned" == "lowcarbon"   ]; then
            compute_point "$mid" "$modifier_expenditures_cautious" "$modifier_expenditures_constrained"
            val_mid=$expenditures_lowcarbon
        elif [ "$tuned" == "cautious"    ]; then
            compute_point "$modifier_expenditures_lowcarbon" "$mid" "$modifier_expenditures_constrained"
            val_mid=$expenditures_cautious
        elif [ "$tuned" == "constrained" ]; then
            compute_point "$modifier_expenditures_lowcarbon" "$modifier_expenditures_cautious" "$mid"
            val_mid=$expenditures_constrained
        fi

        rel_error=$(echo "scale=10; 100 * ($val_mid - $target) / $target" | bc)
        echo "   low: $low; high: $high; mid: $mid; val: $val_mid; target: $target; rel_error: ${rel_error}%; conv: $last_run_is_valid" >&2

       if [ "$last_run_is_valid" == "true" ]; then
            # expenditures decreases as the modifier increases
            if (( $(echo "$val_mid > $target" | bc -l) )); then
                high=$mid
            else
                low=$mid
            fi
        else
            if (( $(echo "$mid > 0" | bc -l) )); then
                high=$mid
            else
                low=$mid
            fi
        fi

        error=$(echo "scale=10; ($high - $low) / 2" | bc)
        if (( $(echo "$error < $tol" | bc -l) )); then break; fi
    done

    echo "scale=10; ($high + $low) / 2" | bc
}


# -----------------------------------------------------------------------------
# Outer fixed-point loop (sequential 1D bisection per group)
# -----------------------------------------------------------------------------
fixed_point_expenditures() {
    local tol_modifiers=$1 tol_expenditures=$2
    local max_loops=15

    local i=0
    local old_lc=$expenditures_lowcarbon0
    local old_ca=$expenditures_cautious0
    local old_co=$expenditures_constrained0
    local diff

    while true; do
        echo ""
        echo "------------- LOOP $i -------------"

        echo '  --- tuning lowcarbon ---'
        modifier_expenditures_lowcarbon=$(bisection_expenditures $tol_modifiers "lowcarbon")
        echo "  final value: $modifier_expenditures_lowcarbon"

        echo '  --- tuning cautious ---'
        modifier_expenditures_cautious=$(bisection_expenditures $tol_modifiers "cautious")
        echo "  final value: $modifier_expenditures_cautious"

        echo '  --- tuning constrained ---'
        modifier_expenditures_constrained=$(bisection_expenditures $tol_modifiers "constrained")
        echo "  final value: $modifier_expenditures_constrained"

        compute_point "$modifier_expenditures_lowcarbon" \
                      "$modifier_expenditures_cautious" \
                      "$modifier_expenditures_constrained"

        echo "  Verification (all modifiers active):"
        echo "    lowcarbon:   got=${expenditures_lowcarbon}  target=${target_lowcarbon}"
        echo "    cautious:    got=${expenditures_cautious}   target=${target_cautious}"
        echo "    constrained: got=${expenditures_constrained}  target=${target_constrained}"

        diff=$(echo "sqrt(($old_lc - $expenditures_lowcarbon)^2 \
                        + ($old_ca - $expenditures_cautious)^2 \
                        + ($old_co - $expenditures_constrained)^2) \
                    / ($old_lc + $old_ca + $old_co)" | bc -l)

        echo "  LOOP $i relative variation: $diff"
        echo "------------- END OF LOOP $i -------------"
        if (( $(echo "$diff < $tol_expenditures" | bc -l) )); then
            echo "  Converged at loop $i"
            break
        fi

        if [ "$i" -ge "$max_loops" ]; then 
            echo "  WARNING: fixed-point loop did not converge after ${max_loops} loops."
            break
        fi

        old_lc=$expenditures_lowcarbon
        old_ca=$expenditures_cautious
        old_co=$expenditures_constrained
        i=$(echo "$i+1" | bc)
    done
}


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
modifier_expenditures_lowcarbon=0
modifier_expenditures_cautious=0
modifier_expenditures_constrained=0
last_run_is_valid=true
expenditures_lowcarbon=0
expenditures_cautious=0
expenditures_constrained=0

banner "CIRCEE modifier_expenditures — T0 calibration (2020)"
echo ""
echo "Propensity ratios at T0:"
echo "   lowcarbon:   ${RATIO_LOWCARBON}"
echo "   cautious:    ${RATIO_CAUTIOUS}"
echo "   constrained: ${RATIO_CONSTRAINED}"
echo ""
echo "Sharing modifiers (fixed):"
echo "   lowcarbon:   ${FIXED_MOD_SH_LOWCARBON:-0}"
echo "   cautious:    ${FIXED_MOD_SH_CAUTIOUS:-0}"
echo "   constrained: ${FIXED_MOD_SH_CONSTRAINED:-0}"

echo ""
echo "--- Baseline run (expenditures modifiers = 0) ---"
compute_point 0 0 0

expenditures_lowcarbon0=$expenditures_lowcarbon
expenditures_cautious0=$expenditures_cautious
expenditures_constrained0=$expenditures_constrained

echo "   Baseline expenditures (Y2020):"
echo "   lowcarbon:   ${expenditures_lowcarbon0}"
echo "   cautious:    ${expenditures_cautious0}"
echo "   constrained: ${expenditures_constrained0}"

target_lowcarbon=$(echo   "scale=10; $expenditures_lowcarbon0   / $RATIO_LOWCARBON"   | bc)
target_cautious=$(echo    "scale=10; $expenditures_cautious0    / $RATIO_CAUTIOUS"    | bc)
target_constrained=$(echo "scale=10; $expenditures_constrained0 / $RATIO_CONSTRAINED" | bc)

chg_lc=$(echo "scale=1; 100*($target_lowcarbon   - $expenditures_lowcarbon0)  / $expenditures_lowcarbon0"   | bc)
chg_ca=$(echo "scale=1; 100*($target_cautious    - $expenditures_cautious0)   / $expenditures_cautious0"    | bc)
chg_co=$(echo "scale=1; 100*($target_constrained - $expenditures_constrained0)/ $expenditures_constrained0" | bc)

echo ""
echo "--- Targets (propensity space) ---"
echo "   lowcarbon:   ${target_lowcarbon}  (${chg_lc}%)"
echo "   cautious:    ${target_cautious}   (${chg_ca}%)"
echo "   constrained: ${target_constrained}  (${chg_co}%)"

fixed_point_expenditures 0.0001 0.0001

{
    echo "lifestyle,modifier_T0,propensity_ratio_T0,target_expenditures,baseline_expenditures"
    echo "lowcarbon,${modifier_expenditures_lowcarbon},${RATIO_LOWCARBON},${target_lowcarbon},${expenditures_lowcarbon0}"
    echo "cautious,${modifier_expenditures_cautious},${RATIO_CAUTIOUS},${target_cautious},${expenditures_cautious0}"
    echo "constrained,${modifier_expenditures_constrained},${RATIO_CONSTRAINED},${target_constrained},${expenditures_constrained0}"
} > "${RESULTS_DIR}/modifiers_expenditures_T0.csv"

mv "$tmp_result_file" "$final_result_file"

banner "DONE — Expenditures modifiers (T0)"
echo "   lowcarbon   = ${modifier_expenditures_lowcarbon}"
echo "   cautious    = ${modifier_expenditures_cautious}"
echo "   constrained = ${modifier_expenditures_constrained}"