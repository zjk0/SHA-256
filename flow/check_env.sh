#!/usr/bin/env bash
# Read-only dependency checks. --local avoids starting Docker.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/env.sh"
[[ $# == 0 || ( $# == 1 && $1 == --local ) ]] || {
    echo 'Usage: check_env.sh [--local]' >&2; exit 2;
}
failures=0
for tool in "$YOSYS" "$IVERILOG" "$VVP" "$MAGIC" "$NETGEN" "$PYTHON" timeout; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '[OK] %s: %s\n' "$tool" "$(command -v "$tool")"
    else
        printf '[MISSING] tool: %s\n' "$tool"
        failures=$((failures + 1))
    fi
done
for file in \
    "$LIBERTY" \
    "$PDK_PATH/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef" \
    "$PDK_PATH/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef" \
    "$PDK_PATH/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds" \
    "$PDK_PATH/libs.ref/sky130_fd_sc_hd/cdl/sky130_fd_sc_hd.cdl" \
    "$PDK_PATH/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice" \
    "$PDK_PATH/libs.ref/sky130_fd_sc_hd/verilog/primitives.v" \
    "$PDK_PATH/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v" \
    "$PDK_PATH/libs.tech/magic/$PDK.magicrc" \
    "$PDK_PATH/libs.tech/netgen/${PDK}_setup.tcl" \
    "$FLOW_DIR/platform/sky130hd/sky130hd.tracks" \
    "$FLOW_DIR/platform/sky130hd/sky130hd.pdn.tcl" \
    "$FLOW_DIR/platform/sky130hd/sky130hd.rc" \
    "$FLOW_DIR/platform/sky130hd/sky130hd.rcx_rules"; do
    if [[ -s $file ]]; then
        printf '[OK] %s\n' "$file"
    else
        printf '[MISSING] %s\n' "$file"
        failures=$((failures + 1))
    fi
done
for file in lvs.py strip_parasitics.py; do
    if [[ ! -f $FLOW_DIR/$file ]]; then
        printf '[BLOCKED: legacy LVS] flow/%s is absent from the repository.\n' "$file"
    fi
done
if [[ ${1:-} != --local ]]; then
    if ! "$FLOW_DIR/openroad.sh" -version; then
        echo '[MISSING] OpenROAD unavailable; check Docker access and OPENROAD_IMAGE.' >&2
        failures=$((failures + 1))
    fi
fi
echo 'Dependency checks do not certify physical signoff; see REPRODUCE.zh-CN.md.'
(( failures == 0 ))
