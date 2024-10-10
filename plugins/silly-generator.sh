#!/bin/bash

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - [$1] $2" >&2
}

input=$(cat)
temp_env_file=$(mktemp)

version_testa=$(echo "$input" | yq e '.functionConfig.spec.version' -)
# log "INFO" "$version_testa"

echo "$input" |yq e '.functionConfig.spec.version | keys[]'| while IFS='' read -r key; do
  value=$(echo "$input" |yq e ".functionConfig.spec.version.$key")
  # log "INFO" "export version_$key=$value"
  echo "export version_$key=$value" >> $temp_env_file
done

source $temp_env_file

replace_vars=$(printenv | grep '^version_' | sed 's/=.*//' | awk '{print "${" $1 "}"}' | tr '\n' ' ')

# log "INFO" "replace_vars: $replace_vars"
# log "INFO" "start env injector....."

echo "$input" | envsubst "$replace_vars"

