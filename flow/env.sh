#!/usr/bin/env bash
# Source this file from Bash. Tool overrides are executable names/paths, not commands.
FLOW_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd -- "$FLOW_DIR/.." && pwd)
export FLOW_DIR PROJECT_ROOT

if [[ -n ${PDK_PATH:-} ]]; then
    PDK_PATH=$(realpath -m -- "$PDK_PATH")
    PDK_ROOT=$(dirname -- "$PDK_PATH")
    PDK=$(basename -- "$PDK_PATH")
else
    PDK_ROOT=$(realpath -m -- "${PDK_ROOT:-/usr/local/share/pdk}")
    PDK=${PDK:-sky130A}
    PDK_PATH="$PDK_ROOT/$PDK"
fi
export PDK_ROOT PDK PDK_PATH
export LIBERTY="$PDK_PATH/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
export OPENROAD_THREADS=${OPENROAD_THREADS:-8}
YOSYS=${YOSYS:-yosys}
IVERILOG=${IVERILOG:-iverilog}
VVP=${VVP:-vvp}
MAGIC=${MAGIC:-magic}
NETGEN=${NETGEN:-netgen}
PYTHON=${PYTHON:-python3}
export YOSYS IVERILOG VVP MAGIC NETGEN PYTHON
