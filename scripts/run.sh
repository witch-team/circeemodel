#!/usr/bin/env bash
# =============================================================================
# Edit config.sh to pick scenarios and set your MATLAB path, then bash run.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export PATH=/usr/local/bin:$PATH

source config.sh
mkdir -p "$RESULTS_DIR"
source lib/parameters.sh
source lib/common.sh
source lib/Full_coupling.sh


validate_config
test_matlab

if [ "$WELFARE_MODE" == "all" ]; then

    # ── Reference run: no modifiers, Baseline sigma scenario ────────────────────────────────────
    # Only meaningful when the main loop is in "coupled" mode in config.sh. In "baseline mode" the
    # 3 scenarios are already modifier-free, so a separate reference would be redundant.
    if [ "$RUN_MODE" == "coupled" ]; then
        echo ""
        echo "================================================================"
        echo "=== REFERENCE RUN: no modifiers (welfare baseline) [${CIRCEE_FORESIGHT}]"
        echo "================================================================"

        _saved_run_mode="$RUN_MODE"
        export RUN_MODE="baseline"
        export CIRCEE_SIGMA_SCENARIO="Baseline"
        run_coupling

        mv "${PATH_GRID_POINT_DATA}welfare_inputs/Baseline_${CIRCEE_FORESIGHT}.mat" \
           "${PATH_GRID_POINT_DATA}welfare_inputs/NoModifiers_${CIRCEE_FORESIGHT}.mat"

        for ext in csv xlsx; do
            src_file="${PATH_GRID_POINT_DATA}CIRCEE_output_levels_Baseline_${CIRCEE_FORESIGHT}.${ext}"
            if [ -f "$src_file" ]; then
                mv "$src_file" "${PATH_GRID_POINT_DATA}CIRCEE_output_levels_NoModifiers_${CIRCEE_FORESIGHT}.${ext}"
            fi
        done

        export RUN_MODE="$_saved_run_mode"
        WELFARE_BASELINE="NoModifiers_${CIRCEE_FORESIGHT}"
    else
        WELFARE_BASELINE="Baseline_${CIRCEE_FORESIGHT}"
    fi

    # ── Main loop: 3 sigma scenarios in whatever RUN_MODE was set ───────
    SCENARIOS=(
        "Baseline"
        "Progressive"
        "Regressive"
    )
    for scen in "${SCENARIOS[@]}"; do
        echo ""
        echo "================================================================"
        echo "=== SCENARIO: $scen [${CIRCEE_FORESIGHT}]"
        echo "================================================================"
        export CIRCEE_SIGMA_SCENARIO="$scen"
        run_coupling
    done

elif [ "$WELFARE_MODE" == "single" ]; then
    export CIRCEE_SIGMA_SCENARIO="$SIGMA_SCENARIO"
    run_coupling
    WELFARE_BASELINE="Baseline_${CIRCEE_FORESIGHT}"

elif [ "$WELFARE_MODE" == "sensitivity" ]; then
    export CIRCEE_SIGMA_SCENARIO="Custom"

    if [ "$BEHAVIOR" == "sharing_only" ]; then
        echo ""
        echo "================================================================"
        echo "=== SENSITIVITY: sharing only | lifestyle=${SCENARIO_SHARING} | sigma=${CIRCEE_SIGMA_VALUE}"
        echo "================================================================"
        export FIXED_MOD_EXP_LOWCARBON=0
        export FIXED_MOD_EXP_CAUTIOUS=0
        export FIXED_MOD_EXP_CONSTRAINED=0
        export LIFESTYLE_SCENARIO=$SCENARIO_SHARING
        bash lib/tune_sharing.sh

    elif [ "$BEHAVIOR" == "sufficiency_only" ]; then
        echo ""
        echo "================================================================"
        echo "=== SENSITIVITY: sufficiency only | lifestyle=${SCENARIO_SUFFICIENCY} | sigma=${CIRCEE_SIGMA_VALUE}"
        echo "================================================================"
        export FIXED_MOD_SH_LOWCARBON=0
        export FIXED_MOD_SH_CAUTIOUS=0
        export FIXED_MOD_SH_CONSTRAINED=0
        export LIFESTYLE_SCENARIO=$SCENARIO_SUFFICIENCY
        bash lib/tune_expenditures.sh
    fi
fi

# ── Welfare post-process ────────────────────────────────────────────────
if [ "$WELFARE_MODE" == "all" ]; then
    (cd "$SRC_DIR" && "$MATLAB_BIN" -batch \
        "CIRCEE_WelfarePostProcess('folder', '../results/grid_point_data/welfare_inputs', 'baseline', '${WELFARE_BASELINE:-Baseline_${CIRCEE_FORESIGHT}}')" \
        > "${RESULTS_DIR}/welfare_logs_${CIRCEE_FORESIGHT}.txt" 2>&1) 2>/dev/null || true

    if grep -q "DONE. Results saved" "${RESULTS_DIR}/welfare_logs_${CIRCEE_FORESIGHT}.txt"; then
        echo "Welfare comparison updated."
    elif grep -q "Baseline file not found" "${RESULTS_DIR}/welfare_logs_${CIRCEE_FORESIGHT}.txt"; then
        echo "Welfare skipped — run Baseline scenario first."
    elif grep -q "Need at least 2 scenarios" "${RESULTS_DIR}/welfare_logs_${CIRCEE_FORESIGHT}.txt"; then
        echo "Welfare skipped — need at least 1 more scenario."
    else
        echo "Welfare skipped — see ${RESULTS_DIR}/welfare_logs_${CIRCEE_FORESIGHT}.txt"
    fi
fi