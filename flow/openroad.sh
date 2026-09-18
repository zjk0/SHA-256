#!/usr/bin/env bash
# Run the project's Tcl scripts with a local binary or a Docker image.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/env.sh"
dry_run=0
if [[ ${1:-} == --dry-run ]]; then
    dry_run=1
    shift
fi

mode=${OPENROAD_MODE:-auto}
case "$mode" in
    auto)
        if command -v "${OPENROAD_BIN:-openroad}" >/dev/null 2>&1; then
            mode=local
        else
            mode=docker
        fi ;;
    local|docker) ;;
    *) echo 'OPENROAD_MODE must be auto, local or docker' >&2; exit 2 ;;
esac
cd "$FLOW_DIR"
if [[ $mode == local ]]; then
    command=("${OPENROAD_BIN:-openroad}" "$@")
else
    docker_command=("${DOCKER_BIN:-docker}")
    if [[ ${DOCKER_SUDO:-0} == 1 ]]; then
        docker_command=(sudo "${docker_command[@]}")
    fi
    # Use identical absolute paths on both sides of the bind mounts. Output
    # remains owned by the host user; only the project is mounted writable.
    command=("${docker_command[@]}" run --rm --init -i
        --user "$(id -u):$(id -g)"
        --mount "type=bind,src=$PROJECT_ROOT,dst=$PROJECT_ROOT"
        --mount "type=bind,src=$PDK_ROOT,dst=$PDK_ROOT,readonly"
        --workdir "$FLOW_DIR"
        --env "PDK_ROOT=$PDK_ROOT" --env "PDK=$PDK" --env "PDK_PATH=$PDK_PATH"
        --env "OPENROAD_THREADS=$OPENROAD_THREADS"
        --entrypoint /bin/bash "${OPENROAD_IMAGE:-openroad/flow-ubuntu22.04-builder:9ed603}"
        -c 'set -e
            if ! command -v "$1" >/dev/null 2>&1; then
                if [[ -f /OpenROAD-flow-scripts/env.sh ]]; then
                    source /OpenROAD-flow-scripts/env.sh
                fi
            fi
            if ! command -v "$1" >/dev/null 2>&1; then
                echo "OpenROAD executable not found: $1 (set OPENROAD_CONTAINER_BIN)" >&2
                exit 127
            fi
            exec "$@"' sha256-openroad "${OPENROAD_CONTAINER_BIN:-openroad}" "$@")
fi
if (( dry_run )); then
    printf '%q ' "${command[@]}"
    printf '\n'
else
    exec "${command[@]}"
fi
