#!/bin/sh

{{ if eq .Values.bashDebug true }}
set -x
pwd
{{ end }}

envsubst <<"EOF" > etc/network-parameters-initial.conf.tmp
notaries : []
minimumPlatformVersion = {{ .Values.mpv }}
maxMessageSize = 10485760
maxTransactionSize = 10485760
eventHorizonDays = 1
EOF

mv etc/network-parameters-initial.conf.tmp etc/network-parameters-initial.conf
cat etc/network-parameters-initial.conf
echo