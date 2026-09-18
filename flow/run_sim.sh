#!/usr/bin/env bash
# Existing FIPS testbench, with the correct source files for each mode.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/env.sh"
mode=${1:-rtl}
args=(-g2012 -s fips_180_4_post_sim_tb)
sources=("$FLOW_DIR/fips_180_4_post_sim_tb.v")
case "$mode" in
    rtl)
        args+=(-I "$PROJECT_ROOT/Verilog")
        sources+=("$PROJECT_ROOT/Verilog/SHA256.v") ;;
    synth|gate)
        netlist="$FLOW_DIR/SHA256_15ns_final.v"
        if [[ $mode == synth ]]; then
            netlist="$FLOW_DIR/SHA256_synth.v"
            args+=(-DSYNTHESIS_SIM)
        fi
        [[ -f $netlist ]] || { echo "Missing netlist: $netlist" >&2; exit 1; }
        model_dir="$PDK_PATH/libs.ref/sky130_fd_sc_hd/verilog"
        args+=(-DPOSTLAYOUT -DFUNCTIONAL -DUNIT_DELAY= -I "$model_dir")
        # Use the installed PDK models so newly mapped cell types are covered.
        # OpenROAD's default write_verilog omits power pins, as does synthesis.
        sources+=("$netlist" "$model_dir/primitives.v" "$model_dir/sky130_fd_sc_hd.v") ;;
    *) echo 'Usage: run_sim.sh [rtl|synth|gate]' >&2; exit 2 ;;
esac
mkdir -p "$FLOW_DIR/.build/$mode"
cd "$FLOW_DIR/.build/$mode"
"$IVERILOG" "${args[@]}" -o "fips_$mode.vvp" "${sources[@]}"
timeout "${SIM_TIMEOUT:-300}" "$VVP" "fips_$mode.vvp" | tee "fips_$mode.log"
