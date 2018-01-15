#! /bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"
source "${DOCKM_HOME}/script/create-ca-server.sh"

# Create a Certificate Authority (CA) server
create_ca_server