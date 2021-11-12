#!/bin/sh

{{ if eq .Values.bashDebug true }}
set -x
{{ end }}

echo "Waiting for etc/network-parameters-initial.conf ..."
until [ -f etc/network-parameters-initial.conf ]
do
    sleep 10
done
echo "Waiting for etc/network-parameters-initial.conf ... done."

ls -al etc/network-parameters-initial.conf
cp etc/network-parameters-initial.conf {{ .Values.nmapJar.configPath }}/
cat {{ .Values.nmapJar.configPath }}/network-parameters-initial.conf

cat {{ .Values.nmapJar.configPath }}/networkmap.conf

if [ ! -f {{ .Values.nmapJar.configPath }}/token ]
then
    EXIT_CODE=1
    until [ "${EXIT_CODE}" -eq "0" ]
    do
        echo "Trying to login to cenm-gateway:8080 ..."
        java -jar bin/cenm-tool.jar context login -s http://cenm-gateway:8080 -u network-maintainer -p p4ssWord
        EXIT_CODE=${?}
        if [ "${EXIT_CODE}" -ne "0" ]
        then
            echo "EXIT_CODE=${EXIT_CODE}"
            sleep 5
        else
            break
        fi
    done
    cat ./etc/network-parameters-initial.conf
    ZONE_TOKEN=$(java -jar bin/cenm-tool.jar zone create-subzone \
        --config-file={{ .Values.nmapJar.configPath }}/networkmap.conf --network-map-address=cenm-nmapb-internal:{{ .Values.adminListener.port }} \
        --network-parameters=./etc/network-parameters-initial.conf --label=Zone2 --label-color='#EFEFEF' --zone-token)
    echo ${ZONE_TOKEN} > {{ .Values.nmapJar.configPath }}/token
    {{ if eq .Values.bashDebug true }}
    cat {{ .Values.nmapJar.configPath }}/token
    {{ end }}
fi
