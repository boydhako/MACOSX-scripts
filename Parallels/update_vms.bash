#!/bin/bash

function STARTVMS {
    for uuid in $(prlctl list -a | awk '{print $1}' | sed -e 's/{//g' -e 's/}//g' ); do
        if [ "$uuid" != "UUID" ]; then
            state="$(prlctl list --info "$uuid" | awk '$1 == "State:" {print $2}')"
            if [ "$state" != "running" ]; then
                prlctl start $uuid &
            elif [ "$state" == "paused" ]; then
                prlctl resume $uuid &
            fi
        fi
    done
    sleep 60
}
function DETECTOS {
    for uuid in $(prlctl list -a | awk '{print $1}' | sed -e 's/{//g' -e 's/}//g' ); do
        if [ "$uuid" != "UUID" ]; then
            vmname="$(prlctl list --all | awk -v uuid="\{$uuid\}" '$1 == uuid {print $NF}')"
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
                id_like="$(prlctl exec $uuid "cat /etc/os-release" | awk -F= '$1 == "ID_LIKE" {print $2}' | sed -e 's/"//g' -e 's/ /_/g')"
                
                case "$id_like" in
                    fedora)
                        id_like=redhat
                        ;;
                    rhel_fedora)
                        id_like=redhat
                        ;;
                esac
                printf "\n=====\nVM Name:\t%s\nVM UUID:\t%s\nOS ID:\t%s\n-----\n" "$vmname" "$uuid" "$id_like"
            elif [ "$os" ==  "windows" ]; then
                id_like="$(prlctl exec $uuid "systeminfo" | awk -F: '$1 == "OS Name" {print $NF}' | sed -e 's/  //g' -e 's/^ //g' | sed 's/ /_/g')"
            elif [ -z "$os" ]; then
                printf "\n\nVM os undetected:\n%s\n\n\n" "$(prlctl list info $uuid)"
            fi
            OSUPDATE 
            unset os
            unset id
            unset id_like
        fi
    done
}
function OSUPDATE {
    case $id_like in
        redhat)
            prlctl snapshot $uuid --description "Scripted update $(date)"
            prlctl exec $uuid "dnf clean all && dnf update -y && dnf distro-sync -y && dnf autoremove -y"
            ;;
        debian)
            prlctl snapshot $uuid --description "Scripted update $(date)"
            prlctl exec $uuid "apt clean all && apt update -y && apt full-upgrade -y && apt auto-remove -y"
            ;;
        *Windows*)
            printf "System is %s.\n" "$id_like"
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
