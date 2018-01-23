#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"
source "${DOCKM_HOME}/script/configure-dockerd.sh"

log_info "Starting docker dameon with TLS"
configure_dockerd