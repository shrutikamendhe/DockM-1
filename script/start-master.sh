#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"

log_info "Running start script"

function load_dockm_image(){
    docker load -i /opt/dockm/image/dockm-image.tar
}

function check_dockm_image(){
    docker_images=$(docker images)
    log_info "$docker_images"
}

USERDATA_FOLDER="/home/ubuntu/userdata"
mkdir -p $USERDATA_FOLDER
function run_dockm_image(){
    docker service create \
    --name click2cloud-dockm \
    --publish 9000:9000 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --mount type=bind,src=$USERDATA_FOLDER,dst=/click2cloud-dockm/data \
    click2cloud/dockm:s2i-newui \
    -H unix:///var/run/docker.sock 
}

CERT_EXPIRY="17520h0m0s"
function docker_init_swarm(){
    retry docker swarm init --cert-expiry ${CERT_EXPIRY} &>/dev/null
}

log_info "Starting docker engine"
docker_start

# Initialize Docker Swarm Manager
log_info "Running docker swarm init command"
docker_init_swarm

log_info "Loading DockM Image"
load_dockm_image

log_info "Checking DockM Image"
check_dockm_image

log_info "Running DockM Image"
run_dockm_image

clean
log_info "Exiting start script"