#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"

HOME="/home/ubuntu"
CERT_FOLDER="${HOME}/.certs"

function configure_dockerd {
    log_info "Starting docker daemon" 
    dockerd --tlsverify --tlscacert="${CERT_FOLDER}/ca.pem" --tlscert="${CERT_FOLDER}/cert.pem" --tlskey="${CERT_FOLDER}/key.pem" -H=0.0.0.0:2376 > /dev/null 2>&1 &
    log_info "Started docker daemon" 
}
