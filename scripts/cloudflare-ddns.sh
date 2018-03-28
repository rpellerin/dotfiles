#!/bin/sh

# Get it from https://api.cloudflare.com/#getting-started-resource-ids
ZONE_IDENTIFIER=

# Get it from https://api.cloudflare.com/#dns-records-for-a-zone-list-dns-records
ENTRY_IDENTIFIER=

CLOUDFLARE_ACCOUNT_EMAIL=

# Get it from Profile
API_KEY=

SUB_DOMAIN_TO_UPDATE=

IP=`lynx -dump http://monip.org | grep 'IP' | sed 's/.*: //;'`

RESULT=`curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_IDENTIFIER/dns_records/$ENTRY_IDENTIFIER" \
     -H "X-Auth-Email: $CLOUDFLARE_ACCOUNT_EMAIL" \
     -H "X-Auth-Key: $API_KEY" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"A\",\"name\":\"$SUB_DOMAIN_TO_UPDATE\",\"content\":\"$IP\"}"`

echo $RESULT >> /tmp/cloudflare-log.txt