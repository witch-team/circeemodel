#!/usr/bin/env bash
# =============================================================================
# CIRCEE-LIFE — User configuration
# =============================================================================
# This is the ONE file you edit before a bash run.sh
# =============================================================================

_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${_CONFIG_DIR}/../src"
RESULTS_DIR="${RESULTS_DIR:-${_CONFIG_DIR}/../results}"
export SRC_DIR RESULTS_DIR

# -----------------------------------------------------------------------------
# 1. RUN MODE
# -----------------------------------------------------------------------------
# Two run modes are available:
#
#   coupled    Full CIRCEE <-> LIFE iterative coupling. Phase 1 jointly
#              calibrates the T0 modifiers; Phase 2 iterates until lifestyle
#              frequency trajectories stabilise. SCENARIO_* settings below
#              control the diffusion narratives.
#
#   baseline   Pure CIRCEE — no behavioural modifiers, no LIFE coupling.
#              All modifiers held at zero. SCENARIO_* settings below are ignored.
# -----------------------------------------------------------------------------
 
RUN_MODE="${RUN_MODE:-coupled}"                 # coupled | baseline 
 
 
# -----------------------------------------------------------------------------
# 2. SCENARIO SELECTION  (used only when RUN_MODE="coupled")
# -----------------------------------------------------------------------------
# Two lifestyle-diffusion regimes are available:
#
#   ecoactive       -> awareness-led diffusion (eco-active narrative)
#   affordability   -> necessity-led diffusion (cost-driven narrative)
#
# Sharing and Sufficiency can be set independently, giving 4 combinations:
#   ecoactive     + ecoactive
#   affordability + affordability
#   ecoactive     + affordability
#   affordability + ecoactive
#
# You have to launch a separate jobrun per lifestyle pair
# -----------------------------------------------------------------------------
 
SCENARIO_SHARING="${SCENARIO_SHARING:-ecoactive}"           # ecoactive | affordability 
SCENARIO_SUFFICIENCY="${SCENARIO_SUFFICIENCY:-affordability}"   # ecoactive | affordability
 
# -----------------------------------------------------------------------------------------------------------------------------
# 3. CIRCEE SCENARIOS
# -----------------------------------------------------------------------------------------------------------------------------
#
# SSP_SCENARIO        Shared Socioeconomic Pathway — population & growth. Only SSP2 available here
# SIGMA_SCENARIO      Cross-group elasticity of substitution sigma at the
#                     end of the simulation horizon.
#                     *** Run Baseline scenario FIRST — it is the reference for
#                         the welfare comparison. Then run the others
#                         in any order. Terminal sigma by 2050 (lowcarbon / cautious / constrained)***
#                              Baseline       (1.9 / 1.5 / 1.1)
#                              Progressive    (2.5 / 3.5 / 4.0)
#                              Regressive     (4.0 / 3.0 / 2.5)
# RUN MODE FOR SCENARIOS single    Run "-single" for one SIGMA_SCENARIO.
#                                  Run "-all" for the three SIGMA_SCENARIO runs sequentially,
#                                  each with its own recalibrated modifiers.
#                                  Attention: "-all" can take up to 10 days on an HPC.
#                                  Recommended: run "-single" for each SIGMA_SCENARIO as a
#                                  separate job (2-3 days each).
#                                  Welfare is not produced by run.sh in either mode. Once all
#                                  runs are complete, run src/CIRCEE_WelfarePostProcess_batch.m.
# -----------------------------------------------------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------------------------
SSP_SCENARIO="${SSP_SCENARIO:-SSP2}" 
SIGMA_SCENARIO="${SIGMA_SCENARIO:-Baseline}"            # Baseline | Progressive | Regressive
WELFARE_MODE="${WELFARE_MODE:-single}"                     # single | all
export WELFARE_MODE

# RUN MODE FOR SCENARIOS single    Run "-single" for one SIGMA_SCENARIO.
#                                  Run "-all" for the three SIGMA_SCENARIO runs sequentially,
#                                  each with its own recalibrated modifiers.
#                                  Attention: "-all" can take up to 10 days on an HPC.
#                                  Recommended: run "-single" for each SIGMA_SCENARIO as a
#                                  separate job (2-3 days each).
#                                  Welfare is not produced by run.sh in either mode. Once all
#                                  runs are complete, run src/CIRCEE_WelfarePostProcess_batch.m.

# -----------------------------------------------------------------------------
# 4. FORESIGHT MODE
# -----------------------------------------------------------------------------
#   perfect_foresight    Agents see the full shock path from period 1.
#   anticipation_errors  Sigma/alppha updated period-by-period (news shocks).
#                        Energy tech is fully anticipated in both modes.
# -----------------------------------------------------------------------------

FORESIGHT_MODE="${FORESIGHT_MODE:-anticipation_errors}"   # perfect_foresight | anticipation_errors
export CIRCEE_FORESIGHT="$FORESIGHT_MODE"

# -----------------------------------------------------------------------------
# 5. YOUR MATLAB PATH
# -----------------------------------------------------------------------------
 
MATLAB_BIN="/Applications/MATLAB_R2024b.app/bin/matlab"
 
 
# -----------------------------------------------------------------------------
# 6. CONVERGENCE  (used only when RUN_MODE="coupled")
# -----------------------------------------------------------------------------
 
MAX_OUTER_ITERATIONS=10      # cap on CIRCEE <-> LIFE outer loop
OUTER_TOL=0.001              # tolerance on frequency change between outer iters
CALIB_TOL=0.0001             # tolerance for joint T0 calibration
MAX_CALIB_ITER=12             # cap on Phase-1 joint calibration loop
 
 
# -----------------------------------------------------------------------------
# 7. PATHS
# -----------------------------------------------------------------------------
 
PATH_GRID_POINT_DATA="${RESULTS_DIR}/grid_point_data/"
REGION=$(grep '@#define REGION' "${SRC_DIR}/CIRCEE_PF.mod" | sed 's/.*"\(.*\)".*/\1/')
PATH_TEMPLATES="${_CONFIG_DIR}/../data/${REGION}/templates/"
 
 
export RUN_MODE
export SCENARIO_SHARING SCENARIO_SUFFICIENCY
export MATLAB_BIN
export MAX_OUTER_ITERATIONS OUTER_TOL CALIB_TOL MAX_CALIB_ITER
export PATH_GRID_POINT_DATA PATH_TEMPLATES
export CIRCEE_SSP_SCENARIO="$SSP_SCENARIO"
export CIRCEE_SIGMA_SCENARIO="${CIRCEE_SIGMA_SCENARIO:-$SIGMA_SCENARIO}"
