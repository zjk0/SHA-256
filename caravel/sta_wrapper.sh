#!/bin/bash
# Wrapper: OpenLane expects 'sta' binary, but OpenROAD integrates STA
set -euo pipefail
exec "$(dirname -- "${BASH_SOURCE[0]}")/../flow/openroad.sh" -no_splash "$@"
