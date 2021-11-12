#!/bin/sh

{{ if eq .Values.bashDebug true }}
set -x
{{ end }}

SUBZONE_ID=$(java -jar bin/cenm-tool.jar zone get-subzones | jq '.subzones[0].id')
    echo ${SUBZONE_ID}
    
ACCESS_TOKEN=""
while [ -z "${ACCESS_TOKEN}" ]
do
    TOKEN_RESPONSE="$(curl -X POST --data "grant_type=password" --data "username=admin" --data "password=p4ssWord" http://cenm-gateway:8080/api/v1/authentication/authenticate)"
    ACCESS_TOKEN="$(echo ${TOKEN_RESPONSE} | jq -r '.access_token')"
    sleep 5
done

for role in "CASigner" "ConfigurationMaintainer" "ConfigurationReader" "NetworkMaintainer" "NetworkOperator" "NetworkOperationsReader" "NonCASigner"; do
 echo "Assigning role ${role} to groups."
 srcFile='/opt/cenm/CM/role-assignments/'$role'.json'
 tempFile=/tmp/$role'.json-tmp'
 sed "s/<SUBZONE_ID>/$SUBZONE_ID/g" $srcFile > $tempFile
 curl -X PATCH -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: application/merge-patch+json" \
      --data-binary "@$tempFile" http://cenm-gateway:8080/api/v1/admin/roles/$role
 echo ""
 rm "$tempFile"
done