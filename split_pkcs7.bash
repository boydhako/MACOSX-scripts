#!/bin/bash -xv
pkcs7="$1"
destdir="$2"

if [ -z "$pkcs7" -o ! -f "$pkcs7" ]; then
    printf "\nNeed to specify the PKCS7 file.\n\n"
    exit 1
fi

if [ -z "$destdir" -o ! -d "$destdir" ]; then
    printf "\nNeed to specify destination directory for files.\n\n"
    exit 1
fi

mimetype="$(file --mime-type $pkcs7 | awk -F: '{print $NF}' | sed 's/^ //')"

case $mimetype in
    application/octet-stream)
        format="DER"
    ;;
    text/plain)
        format="PEM"
    ;;
esac

for eline in $(openssl pkcs7 -inform $format -in $pkcs7 -print_certs | egrep -n -e "-----END CERTIFICATE-----" | awk -F: '{print $1}'); do
    for bline in $(openssl pkcs7 -inform $format -in $pkcs7 -print_certs | egrep -n -e "-----BEGIN CERTIFICATE-----" | awk -F: '{print $1}'); do
        tempcert="$destdir/temp.crt"
        openssl pkcs7 -inform $format -in $pkcs7 -print_certs | head -$eline | tail +$bline | openssl x509 -text -out $tempcert 2>/dev/null | awk -F= '{print $NF}'
        subject="$(openssl x509 -in $tempcert -subject -noout | awk -F = '{print $NF}' | sed -e 's/^ //g' -e 's/ /_/g')"
        hash="$(openssl x509 -in $tempcert -hash -noout | awk -F = '{print $NF}' | sed -e 's/^ //g' -e 's/ /_/g')"
        openssl x509 -in $tempcert -out "$destdir/$subject-$hash-PEM.crt" -text
        chmod 444 "$destdir/$subject-$hash-PEM.crt"
        rm -f $tempcert
      done
done
