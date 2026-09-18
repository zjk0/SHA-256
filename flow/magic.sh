#!/usr/bin/env bash
# Initialize the PDK technology and propagate Tcl errors to the caller.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/env.sh"
[[ $# == 1 ]] || { echo 'Usage: magic.sh script.tcl' >&2; exit 2; }
case $1 in
    /*) export SHA256_MAGIC_SCRIPT=$1 ;;
    *) export SHA256_MAGIC_SCRIPT="$FLOW_DIR/$1" ;;
esac
[[ -f $SHA256_MAGIC_SCRIPT ]] || { echo "Missing script: $SHA256_MAGIC_SCRIPT" >&2; exit 1; }
magic_rc="$PDK_PATH/libs.tech/magic/$PDK.magicrc"
[[ -f $magic_rc ]] || { echo "Missing Magic technology: $magic_rc" >&2; exit 1; }
cd "$FLOW_DIR"
"$MAGIC" -dnull -noconsole -rcfile "$magic_rc" <<'TCL'
if {[catch {source $env(SHA256_MAGIC_SCRIPT)} message]} {
    puts stderr $::errorInfo
    exit 1
}
quit -noprompt
TCL
