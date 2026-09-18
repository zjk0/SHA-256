#!/usr/bin/env bash
# Compatibility entry: reuse the existing synthesis netlist, then PnR + FIPS.
set -euo pipefail
exec "$(dirname -- "${BASH_SOURCE[0]}")/run_all.sh" --pnr-only --skip-synth "$@"
