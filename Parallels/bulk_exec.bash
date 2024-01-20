#!/bin/bash
status="$1"
cmd="$2"

function PREP {
    case $status in
        stopped)
        ;;
        running)
        ;;
        all)
        ;;
        *)
            printf "Not a recognized status.\n"
            exit 1
        ;;
    esac
    case $cmd in
        "")
            printf "Need to state what prlctl subcommand to run.\n"
            exit 1
        ;;
    esac

    if [ "$status" == "all" ]; then
        for id in $(prlctl list -a | egrep -v -e "^UUID" | awk '{print $1}'); do
            CMD $id
        done
    else
        for id in $(prlctl list -a | egrep -v -e "^UUID" | awk -v status="$status" '$2 == status {print $1}'); do
            CMD $id
        done
    fi
}

function CMD {
    id=$1
    prlctl $cmd $id
}
function BULKEXEC {
    PREP
}
BULKEXEC
