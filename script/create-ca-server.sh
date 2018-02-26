#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"

HOME="/home/ubuntu"
CERT_FOLDER="${HOME}/.certs"

function cert_folder {
    if [ ! -d "${CERT_FOLDER}" ]; then
        mkdir -p "${CERT_FOLDER}"
    fi
}

function create_priv_key {
    openssl genrsa -out $1-priv-key.pem 2048 &>/dev/null
}

function generate_csr {
    openssl req -subj "/CN=$1" -new -key $1-priv-key.pem -out $1.csr &>/dev/null
}

function create_public_key {
    openssl x509 -req -days 1825 -in $1.csr -CA ca.pem -CAkey ca-priv-key.pem -CAcreateserial -out $1-cert.pem -extensions v3_req -extfile /usr/lib/ssl/openssl.cnf &>/dev/null
    openssl rsa -in $1-priv-key.pem -out $1-priv-key.pem &>/dev/null
}

function create_ca_server { 
    pushd $CERT_FOLDER &>/dev/null

    # Create a private key called 'ca-priv-key.pem' for the CA
    create_priv_key "ca"

    HOSTNAME=$(hostname -f)

    # Create a public key called 'ca.pem' for the CA.
    openssl req -config /usr/lib/ssl/openssl.cnf -new -key ca-priv-key.pem -x509 -days 1825 -out ca.pem -subj "/C=US/ST=CA/L=San Francisco/O=Docker Inc/OU=Sales/CN=${HOSTNAME}" &>/dev/null

    popd &>/dev/null
}

function create_node_certificate {
    pushd $CERT_FOLDER &>/dev/null

    # Create a private
    create_priv_key $1

    # Generate a certificate signing request (CSR) *.csr using the private key.
    generate_csr $1

    # Create the certificate *-cert.pem based on the CSR .
    create_public_key $1
    
    popd &>/dev/null
}

function install_key {
    scp -i ${HOME}/.ssh/id_rsa ${CERT_FOLDER}/ca.pem $2@$1:${CERT_FOLDER}/ca.pem &>/dev/null
    scp -i ${HOME}/.ssh/id_rsa ${CERT_FOLDER}/$1-cert.pem $2@$1:${CERT_FOLDER}/cert.pem &>/dev/null
    scp -i ${HOME}/.ssh/id_rsa ${CERT_FOLDER}/$1-priv-key.pem $2@$1:${CERT_FOLDER}/key.pem &>/dev/null
}

# Create certificate folder on start of script
cert_folder
