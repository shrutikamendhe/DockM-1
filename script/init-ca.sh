#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"
source "${DOCKM_HOME}/script/create-ca-server.sh"

log_info "Running initialization CA server script"

# Create a Certificate Authority (CA) server
log_info "Creating Certificate Authority (CA) server" 
create_ca_server

CLUSTER_INFO="${DOCKM_HOME}/cluster-info"
if [  -f "${CLUSTER_INFO}" ]; then
    while IFS=' ' read -r f1 f2 f3
    do
        if [ ! -z "${f2// }" ]; then
            log_info "Creating and installing cert for ${f2}" 
            create_node_certificate $f2
            install_key $f2 "ubuntu"
            log_info "Created and installed cert for ${f2}" 
        fi
    done < "$CLUSTER_INFO"
fi

log_info "End of initialization CA server script" 