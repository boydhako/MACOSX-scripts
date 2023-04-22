#!/bin/bash -xv
sshdir="$HOME/.ssh"
awsconfig="$sshdir/aws.config"

function PREP {
    export PATH="$PATH:/usr/local/bin"
    if [ ! -d "$sshdir" ]; then
        mkdir -p $sshdir
        chmod 750 $sshdir
    fi

    if [ -f "$awsconfig" ]; then
        rm -f $awsconfig
    fi
    #CLEANHOSTS
}

function CLEANHOSTS {
    grep -vie "amazonaws" $sshdir/known_hosts > $sshdir/known_hosts.tmp
    mv -f $sshdir/known_hosts.tmp $sshdir/known_hosts
}

function GENAWSCFG {
    for instid in $(aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].{Instance:InstanceId}'); do
        #aws ec2 describe-instances --output text --instance-ids $instid --query 'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`]|[0].Value,NetworkInterfaces:PublicDnsName}'
        name="$(aws ec2 describe-instances --output text --instance-ids $instid --query 'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`]|[0].Value}')"
        pubdns="$(aws ec2 describe-instances --output text --instance-ids $instid --query 'Reservations[*].Instances[*].{NetworkInterfaces:PublicDnsName}')"

        if [ ! -z "$pubdns" ]; then
            printf "host %s\n\thostname %s\n\tuser ec2-user\n" "$name" "$pubdns" >> $awsconfig
            ssh -o "UpdateHostkeys yes" -o "StrictHostKeyChecking no" -i /Users/bako/.ssh/cronjob-id_rsa $name "hostname -f" 
        fi
    done
    chmod 600 $awsconfig
}
function GENAWSSSHCFNG {
    PREP
    CLEANHOSTS
    GENAWSCFG
}
GENAWSSSHCFNG
