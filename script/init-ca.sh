#! /bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"
source "${DOCKM_HOME}/script/create-ca-server.sh"

# Create a Certificate Authority (CA) server
create_ca_server

cluster_conf_file="${DOCKM_HOME}/cluster-info"

while IFS=: read -r f1 f2
do
    create_node_certificate $f1
    install_key $f1 "ubuntu"
done < "$cluster_conf_file"