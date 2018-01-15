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

function create_ca_server {
    cert_folder

    pushd $CERT_FOLDER

    # Create a private key called 'ca-priv-key.pem' for the CA
    openssl genrsa -out ca-priv-key.pem 2048

    HOSTNAME=$(hostname -f)

    # Create a public key called 'ca.pem' for the CA.
    openssl req -config /usr/lib/ssl/openssl.cnf -new -key ca-priv-key.pem -x509 -days 1825 -out ca.pem -subj "/C=US/ST=CA/L=San Francisco/O=Docker Inc/OU=Sales/CN=${HOSTNAME}"

    popd
}