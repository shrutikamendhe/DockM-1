#!/bin/bash
data=("$(curl http://localhost:9323/metrics -s | grep engine_daemon_container_states_containers)")

# Save current IFS
SAVEIFS=$IFS

# Change IFS to new line. 
IFS=$'\n'
data=($data)

# Restore IFS
IFS=$SAVEIFS


fd_paused=0
fd_running=0
fd_stopped=0

for (( i=0; i<${#data[@]}; i++ ))
do
    tmp=$(echo "${data[$i]}")
    if [[ $tmp != '#'* ]]; then
        if [[ $tmp = *'state="paused"'* ]]; then
            fd_paused=$(echo $tmp | cut -d ' ' -f 2)
        elif [[ $tmp = *'state="running"'* ]]; then
            fd_running=$(echo $tmp | cut -d ' ' -f 2)
        elif [[ $tmp = *'state="stopped"'* ]]; then
            fd_stopped=$(echo $tmp | cut -d ' ' -f 2)
        fi
    fi
done 

echo "{\"engine_daemon_container_states_containers_paused\":$fd_paused,\"engine_daemon_container_states_containers_running\":$fd_running,\"engine_daemon_container_states_containers_stopped\":$fd_stopped}"