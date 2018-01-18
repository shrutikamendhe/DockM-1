#! /bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"

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
    pushd $CERT_FOLDER

    # Create a private key called 'ca-priv-key.pem' for the CA
    create_priv_key "ca"

    HOSTNAME=$(hostname -f)

    # Create a public key called 'ca.pem' for the CA.
    openssl req -config /usr/lib/ssl/openssl.cnf -new -key ca-priv-key.pem -x509 -days 1825 -out ca.pem -subj "/C=US/ST=CA/L=San Francisco/O=Docker Inc/OU=Sales/CN=${HOSTNAME}" &>/dev/null

    popd
}

function create_node_certificate {
    pushd $CERT_FOLDER

    # Create a private
    create_priv_key $1

    # Generate a certificate signing request (CSR) *.csr using the private key.
    generate_csr $1

    # Create the certificate *-cert.pem based on the CSR .
    create_public_key $1
    
    popd
}

function install_key {
    
    #ssh -i ${HOME}/.ssh/id_rsa $2@$1 'mkdir -p ${HOME}/.certs' &>/dev/null

    scp -i ${HOME}/.ssh/id_rsa ${HOME}/cert/ca.pem $2@$1:${HOME}/.certs/ca.pem &>/dev/null
    scp -i ${HOME}/.ssh/id_rsa ${HOME}/cert/$1-cert.pem $2@$1:${HOME}/.certs/cert.pem &>/dev/null
    scp -i ${HOME}/.ssh/id_rsa ${HOME}/cert/$1-priv-key.pem $2@$1:${HOME}/.certs/key.pem &>/dev/null
}

# Create certificate folder on start of script
cert_folder
