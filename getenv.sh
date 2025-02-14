#!/usr/bin/env bash -euo pipefail

container_name="$1"
shift

env_vars=$(docker inspect ${container_name} -f '{{range .Config.Env}}{{println .}}{{end}}')

output=""

for var_name in "$@"
do
    env_var=$(echo "$env_vars" | grep "$var_name=")
    if [[ -z "$env_var"  ]]; then
        echo "environment variable ${var_name} not found in the container ${container_name}" >&2
        return 1
    fi

    export "$env_var"
done
