#!/bin/bash

LOG_FILE="/logs/cluster_logs"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

function log_info { 
    log_common "INFO" "$1"
}

function log_warn {
    log_common "WARN" "$1" 
}

function log_error {
    log_common "ERROR" "$1"
}

function log_common {
    dt=$(date '+%F %T')
    echo "[$1]: $dt $2" &>> ${LOG_FILE}
}

function fail {
    log_error "$1"
    exit 1
}

function retry {
    local COUNTER=1
    local MAX=5
    local delay=5
    while true; do
        "$@" && break || {
            if [[ $COUNTER -lt $MAX ]]; then
                log_info "Command failed. Attempt $COUNTER/$MAX:"
                COUNTER=$[$COUNTER +1]
                sleep $delay;
            else
                fail "The command has failed after $COUNTER attempts."
                break;
            fi
        }
    done
}

function docker_start () {
    retry systemctl start docker
    chmod 666 /var/run/docker.sock
}

function docker_stop () {
    retry systemctl stop docker
}

function docker_restart () {
    retry systemctl restart docker
    chmod 666 /var/run/docker.sock
}

function docker_active(){
    systemctl is-active docker
}

function docker_leave_swarm(){
    retry docker swarm leave --force
}
