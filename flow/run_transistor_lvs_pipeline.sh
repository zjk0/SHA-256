#!/usr/bin/env bash
# Historical standard-cell LVS pipeline. See REPRODUCE.zh-CN.md for limitations.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/env.sh"
cd "$FLOW_DIR"
for file in strip_parasitics.py lvs.py; do
    [[ -f $file ]] || {
        echo "Missing upstream helper: $file; cannot run this LVS pipeline." >&2
        exit 2
    }
done
[[ -f SHA256_15ns.schematic.v6pos.cdl ]] || {
    echo 'Run run_lvs_15ns.py first to generate the schematic CDL.' >&2
    exit 2
}
"$FLOW_DIR/magic.sh" run_magic_extract_spice.tcl
"$PYTHON" strip_parasitics.py
"$PYTHON" fix_layout_subckts.py
"$PYTHON" rename_clkload_nets.py
"$PYTHON" make_schematic_spice.py
"$PYTHON" fix_pin_order.py
mkdir -p .build/lvs/layout .build/lvs/schematic
cp SHA256_15ns_transistor_lvs_ready.spice .build/lvs/layout/SHA256
cp SHA256_15ns_schematic_transistor.cdl .build/lvs/schematic/SHA256
"$NETGEN" -batch source "$FLOW_DIR/run_transistor_lvs.tcl" 2>&1 | tee .build/lvs/netgen.log
echo 'Review SHA256_15ns_transistor_lvs.report; process exit alone is not LVS proof.'
