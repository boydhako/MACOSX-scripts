#!/bin/bash

function STARTVMS {
    for uuid in $(prlctl list -a | awk '{print $1}' | sed -e 's/{//g' -e 's/}//g' ); do
        if [ "$uuid" != "UUID" ]; then
            state="$(prlctl list --info $uuid | awk '$1 == "State:" {print $2}')"
            if [ "$state" != "running" ]; then
                prlctl start $uuid &
            elif [ "$state" == "paused" ]; then
                prlctl resume $uuid &
            fi
        fi
    done
    sleep 60s
}
function DETECTOS {
    for uuid in $(prlctl list -a | awk '{print $1}' | sed -e 's/{//g' -e 's/}//g' ); do
        prlctl exec $uuid "uname -a" > /dev/null 2>&1
        if [ "$(echo $?)" == "0" ]; then
            os=linux
        fi
        prlctl exec $uuid "systeminfo" > /dev/null 2>&1
        if [ "$(echo $?)" == "0" ]; then
            os=windows
        fi
        if [ "$os" == "linux" ]; then
            id="$(prlctl exec $uuid "cat /etc/os-release" | awk -F= '$1 == "ID" {print $2}')"
            id_like="$(prlctl exec $uuid "cat /etc/os-release" | awk -F= '$1 == "ID_LIKE" {print $2}')"
            
            if [ ! -z "$id_like" ]; then
                echo $id_like
            else
                case $id in
                    fedora)
                        id_like=redhat
                        ;;
                esac
            fi
            printf "\n\n%s : %s\n\n\n" "$uuid" "$id_like"
        elif [ "$os" ==  "windows" ]; then
            prlctl exec $uuid "systeminfo" | awk -F: '$1 == "OS Name" {print $NF}' | sed 's/ /_/g'
        elif [ -z "$os" ]; then
            printf "\n\nVM os undetected:\n%s\n\n\n" "$(prlctl list info $uuid)"
        fi
        OSUPDATE 
        unset os
        unset id
        unset id_like
    done
}
function OSUPDATE {
    case $id_like in
        redhat)
            prlctl exec $uuid "dnf clean all && dnf update -y && dnf distro-sync -y && dnf autoremove -y"
            ;;
        debian)
            prlctl exec $uuid "apt clean all && apt update -y && apt full-upgrade -y && apt auto-remove -y"
            ;;
    esac
    if [ "$os" == "linux" ]; then
        prlctl exec $uuid "shutdown now"
    fi
}
function UPDATEVMS {
    STARTVMS
    DETECTOS
}
UPDATEVMS
