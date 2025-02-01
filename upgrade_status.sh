#!/bin/bash
primary="$(puppet config print server)"
auth_header="X-Authentication: $(puppet-access show)"
type_header='Content-Type: application/json'
uri="https://$primary:8143/orchestrator/v1/command/task"
cacert="$(puppet config print localcacert)"

curl="curl --cacert ${cacert} --silent"

taskdata='
{ "scope": {
    "nodes": [ "'${primary}'" ] },
  "params": {
    "action": "status",
    "name": "peadmmig@profiles::upgradeto2021.service" },
  "task": "service::linux",
  "environment": "production"
}'

echo '# URL'
echo $curl
echo '# PAYLOAD'
echo "$taskdata" | jq .

#curl --insecure --header "$type_header" --header "$auth_header" --request POST "$uri" --data "$taskdata"
url=$(${curl} --header "$type_header" --header "$auth_header" --request POST "$uri" --data "$taskdata" | jq --raw-output .job.id)

# folgendes pollen bis .state == finished
echo '# RESPONSE 1'

${curl} --request GET "${url}" | jq --raw-output .state

echo '# RESPONSE 2'

${curl} --request GET "${url}" | jq --raw-output .state

# wenn .state == finished, dann ausgabe vom task auslesen
echo '# RESPONSE 3'
#${curl} --header "$type_header" --header "$auth_header" "${url}/events" | jq '.items | .[] | select(.type=="node_finished").details.detail.status' --raw-output
${curl} --header "$type_header" --header "$auth_header" "${url}/events" | jq .
