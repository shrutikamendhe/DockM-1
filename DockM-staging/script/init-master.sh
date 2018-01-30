#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"

log_info "Initalizing docker swarm master"

CERT_EXPIRY="17520h0m0s"
function docker_init_swarm(){
    retry docker swarm init --cert-expiry ${CERT_EXPIRY} &>/dev/null
}

log_info "Restrating docker service"
docker_restart

# Initialize Docker Swarm Manager
log_info "Running initialize docker swarm init command"
docker_init_swarm
log_info "Initialized docker swarm master"