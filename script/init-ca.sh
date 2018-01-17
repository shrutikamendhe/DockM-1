#! /bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

pushd $DOCKM_HOME
wget -O /opt/dockm/script/common.sh https://raw.githubusercontent.com/shrutikamendhe/DockM-QingCloud/dev/script/common.sh
wget -O /opt/dockm/script/create-ca-server.sh https://raw.githubusercontent.com/shrutikamendhe/DockM-QingCloud/dev/script/create-ca-server.sh;
chmod +x /opt/dockm/script/*
popd

source "${DOCKM_HOME}/script/common.sh"
source "${DOCKM_HOME}/script/create-ca-server.sh"

# Create a Certificate Authority (CA) server
create_ca_server

# Create a certificate for Swarm Manager
create_node_certificate "swarm"

# Create a certificate for Node1 
create_node_certificate "node1"

# Create a certificate for Node2 
create_node_certificate "node2"

# Create a certificate for Client Manager
create_node_certificate "client"

