#!/bin/bash
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
    CLEANHOSTS
}

function CLEANHOSTS {
    sed -i '' 's/.*\.amazonaws\..*//g' $sshdir/known_hosts
}

function GENAWSCFG {
    printf "# Generated on %s\n\n" "$(date)" > $awsconfig
    for instid in $(aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].{Instance:InstanceId}'); do
        #aws ec2 describe-instances --output text --instance-ids $instid --query 'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`]|[0].Value,NetworkInterfaces:PublicDnsName}'
        name="$(aws ec2 describe-instances --output text --instance-ids $instid --query 'Reservations[*].Instances[*].{Name:Tags[?Key==`Name`]|[0].Value}')"
        pubdns="$(aws ec2 describe-instances --output text --instance-ids $instid --query 'Reservations[*].Instances[*].{NetworkInterfaces:PublicDnsName}')"

        if [ ! -z "$pubdns" ]; then
            printf "host %s\n\thostname %s\n\tuser ec2-user\n\tUpdateHostKeys yes\n" "$name" "$pubdns" >> $awsconfig
            #ssh -o "UpdateHostkeys yes" -o "StrictHostKeyChecking no" -i /Users/bako/.ssh/cronjob-id_rsa $name "hostname -f" 
            ssh-keyscan $pubdns >> $sshdir/known_hosts 2>/dev/null
        fi
    done
    chmod 600 $awsconfig
}
function GENAWSSSHCFNG {
    curl -k https://ec2.us-west-2.amazonaws.com
    if [ "$?" != "0" ]; then
        exit 1
    fi
    PREP
    CLEANHOSTS
    GENAWSCFG
}
GENAWSSSHCFNG
