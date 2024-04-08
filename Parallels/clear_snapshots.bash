#!/bin/bash -xv

for uuid in $(prlctl list --all | awk '$1 != "UUID" {print $1}' | sed -e 's/{//g' -e 's/}//g'); do
    for snapshotid in $(prlctl snapshot-list $uuid | awk '$2 != "SNAPSHOT_ID" {print $NF}' | sed -e 's/^.*{//g' -e 's/}//g'); do
        prlctl snapshot-delete $uuid --id $snapshotid --children
        prlctl snapshot-delete $uuid --id $snapshotid

    done
done