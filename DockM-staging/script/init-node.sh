#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"

log_info "Initalizing docker worker node"

SSH_FOLDER="/home/ubuntu/.ssh/"
function docker_join_swarm(){
    token_result=$(ssh -i ${SSH_FOLDER}/id_rsa ubuntu@master "docker swarm join-token worker")
    while IFS=':' read -ra STR; do
      for s in "${STR[@]}"; do
        if [[ "$s" = *"docker swarm join"* ]]; then
        #if [[ "$s" = *"docker swarm join"* ]] || [ "$s" = "2377" ]; then
            cmd="$s"
        fi
      done
    done <<< "$token_result"

    swarm_join_cmd="$cmd:2377"
    $swarm_join_cmd
}

log_info "Restrating docker service"
docker_restart

# Initialize Docker Swarm Worker
log_info "Joining docker swarm cluster"
docker_join_swarm
log_info "Initialized docker worker node"