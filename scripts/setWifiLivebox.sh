#!/bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: ./wifiLivebox.sh true|false" >&2
  exit 1
fi

request=$(curl -s -c /tmp/cookies_livebox_script 'http://192.168.1.1/authenticate?username=admin&password=admin' --data '')

contextID=$(echo $request | awk -F '"contextID":"' '{ print $2}' | awk -F '"}}' '{ print $1 }')

if [ "$1" = "false" ]; then
  curl -b /tmp/cookies_livebox_script 'http://192.168.1.1/sysbus/NMC/Wifi:set' -H "X-Context: $contextID" -H 'Content-type: application/x-sah-ws-1-call+json; charset=UTF-8' -H 'Referer: http://192.168.1.1/configWifi.html' --data-binary '{"parameters":{"Enable":false,"Status":false}}'
elif [ "$1" = "true" ]; then
  curl -b /tmp/cookies_livebox_script 'http://192.168.1.1/sysbus/NMC/Wifi:set' -H "X-Context: $contextID" -H 'Content-type: application/x-sah-ws-1-call+json; charset=UTF-8' -H 'Referer: http://192.168.1.1/configWifi.html' --data-binary '{"parameters":{"Enable":true,"Status":true}}'
fi

rm /tmp/cookies_livebox_script