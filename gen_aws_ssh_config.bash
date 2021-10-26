#!/bin/bash
sshdir="$HOME/.ssh"
awsconfig="$sshdir/aws.config"

function PREP {
    if [ ! -d "$sshdir" ]; then
        mkdir -p $sshdir
        chmod 750 $sshdir
    fi

    if [ -f "$awsconfig" ]; then
        touch $awsconfig
        chmod 640 $awsconfig
    fi
    CLEANHOSTS
}

function CLEANHOSTS {
    sed -i '' -e 's#^.*\.compute\.amazonaws\.com,.*##g' $sshdir/known_hosts
}

function GENAWSCFG {
    for instid in $(aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].{Instance:InstanceId}'); do
        #aws ec2 describe-instances --output text --instance-ids $instid --query 'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`]|[0].Value,NetworkInterfaces:PublicDnsName}'
        name="$(aws ec2 describe-instances --output text --instance-ids $instid --query 'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`]|[0].Value}')"
        pubdns="$(aws ec2 describe-instances --output text --instance-ids $instid --query 'Reservations[*].Instances[*].{NetworkInterfaces:PublicDnsName}')"

        printf "host %s\n\thostname %s\n" "$name" "$pubdns" >> $awsconfig
    done
}
function GENAWSSSHCFNG {
    PREP
    #GENAWSCFG
}
GENAWSSSHCFNG
