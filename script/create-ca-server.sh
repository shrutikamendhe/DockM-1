#! /bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
DOCKM_HOME=$(dirname "${SCRIPTPATH}")

source "${DOCKM_HOME}/script/common.sh"

CERT_FOLDER="${HOME}/cert"

function cert_folder {
    if [ ! -d "${CERT_FOLDER}" ]; then
        mkdir -p "${CERT_FOLDER}"
    fi
}

function create_priv_key {
    openssl genrsa -out $1-priv-key.pem 2048
}

function generate_csr {
    openssl req -subj "/CN=$1" -new -key $1-priv-key.pem -out $1.csr
}

function create_public_key {
    openssl x509 -req -days 1825 -in $1.csr -CA ca.pem -CAkey ca-priv-key.pem -CAcreateserial -out $1-cert.pem -extensions v3_req -extfile /usr/lib/ssl/openssl.cnf
    openssl rsa -in $1-priv-key.pem -out $1-priv-key.pem
}

function create_ca_server {
    pushd $CERT_FOLDER

    # Create a private key called 'ca-priv-key.pem' for the CA
    create_priv_key "ca"

    HOSTNAME=$(hostname -f)

    # Create a public key called 'ca.pem' for the CA.
    openssl req -config /usr/lib/ssl/openssl.cnf -new -key ca-priv-key.pem -x509 -days 1825 -out ca.pem -subj "/C=US/ST=CA/L=San Francisco/O=Docker Inc/OU=Sales/CN=${HOSTNAME}"

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

# Create certificate folder on start of script
cert_folder
