#!/usr/bin/env bash
# Compatibility entry; use this checkout's RTL without copying Windows files.
set -euo pipefail
exec "$(dirname -- "${BASH_SOURCE[0]}")/run_synth.sh" "$@"
