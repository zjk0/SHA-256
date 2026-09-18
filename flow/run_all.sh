#!/usr/bin/env bash
# Local simulation/synthesis/Magic/Netgen; OpenROAD via openroad.sh.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/env.sh"
cd "$FLOW_DIR"
skip_synth=0
signoff_only=0
pnr_only=0
for arg in "$@"; do
    case $arg in
        --skip-synth) skip_synth=1 ;;
        --signoff-only) signoff_only=1; skip_synth=1 ;;
        --pnr-only) pnr_only=1 ;;
        -h|--help)
            echo 'Usage: run_all.sh [--pnr-only] [--skip-synth] [--signoff-only]'
            echo '--pnr-only: RTL simulation, synthesis, PnR and gate simulation.'
            echo 'Full verification requires the missing upstream flow/lvs.py.'
            exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
done
if (( pnr_only && signoff_only )); then
    echo '--pnr-only and --signoff-only cannot be combined.' >&2
    exit 2
fi
if (( ! pnr_only )) && [[ ! -f $FLOW_DIR/lvs.py ]]; then
    echo 'Full verification is blocked: flow/lvs.py is missing from this checkout.' >&2
    echo 'Restore it before LVS, or run --pnr-only to reproduce through PnR.' >&2
    echo 'See REPRODUCE.zh-CN.md for the remaining signoff limitations.' >&2
    exit 2
fi
if (( signoff_only )); then
    for file in SHA256_15ns.def SHA256_15ns_final.v SHA256_15ns.spef; do
        [[ -s $file ]] || { echo "Missing prerequisite: $file" >&2; exit 1; }
    done
elif (( skip_synth )); then
    [[ -s SHA256_synth.v ]] || { echo 'Missing SHA256_synth.v' >&2; exit 1; }
fi
mkdir -p .build
run_step() {
    local label=$1
    shift
    printf '\nRunning %s\n' "$label"
    "$@" 2>&1 | tee ".build/$label.log"
}
run_step openroad_version "$FLOW_DIR/openroad.sh" -version
if (( ! signoff_only )); then
    run_step rtl "$FLOW_DIR/run_sim.sh" rtl
    if (( ! skip_synth )); then
        run_step synthesis "$FLOW_DIR/run_synth.sh"
    fi
    run_step pnr "$FLOW_DIR/openroad.sh" -no_init -exit openroad_flow_15ns_signoff.tcl
fi
run_step gate "$FLOW_DIR/run_sim.sh" gate
if (( pnr_only )); then
    echo 'PnR and functional simulation completed. Physical signoff has not been run.'
    exit 0
fi
run_step area "$FLOW_DIR/openroad.sh" -no_init -exit run_area_report.tcl
run_step gds "$FLOW_DIR/magic.sh" run_magic_gds.tcl
run_step magic_drc "$FLOW_DIR/magic.sh" run_magic_drc_signoff.tcl
run_step antenna "$FLOW_DIR/openroad.sh" -no_init -exit run_antenna_check.tcl
run_step lvs_connectivity "$PYTHON" run_lvs_15ns.py
run_step power "$FLOW_DIR/openroad.sh" -no_init -exit run_power_ir_signoff.tcl
run_step ir_drop "$FLOW_DIR/openroad.sh" -no_init -exit run_ir_drop_real.tcl
echo 'Requested analysis commands completed. Review timing/DRC/antenna/IR reports.'
echo 'The DEF/Verilog LVS above is a connectivity comparison, not extracted transistor LVS.'
