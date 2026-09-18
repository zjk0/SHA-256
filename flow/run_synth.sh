#!/usr/bin/env bash
# Render the Yosys script with this checkout and PDK, then synthesize locally.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/env.sh"
case ${1:-synth.ys} in
    synth.ys|synth_98mhz.ys) synth_script=${1:-synth.ys} ;;
    *) echo 'Usage: run_synth.sh [synth.ys|synth_98mhz.ys]' >&2; exit 2 ;;
esac
[[ -f $LIBERTY ]] || { echo "Liberty not found: $LIBERTY" >&2; exit 1; }
mkdir -p "$FLOW_DIR/.build"
"$PYTHON" - "$FLOW_DIR/$synth_script" "$FLOW_DIR/.build/$synth_script" <<'PY'
import os
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text()
for key in ("PROJECT_ROOT", "FLOW_DIR", "LIBERTY"):
    # The template already quotes paths; escape for the Yosys command parser.
    value = os.environ[key].replace("\\", "\\\\").replace('"', '\\"')
    text = text.replace("@" + key + "@", value)
Path(sys.argv[2]).write_text(text)
PY
cd "$FLOW_DIR"
exec "$YOSYS" -l "$FLOW_DIR/.build/${synth_script%.ys}.log" -s "$FLOW_DIR/.build/$synth_script"
