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
    "name": "peadmmig@profiles::convert.service" },
  "task": "service::linux",
  "environment": "peadm"
}'

echo '# URL'
echo "$curl"
echo '# PAYLOAD'
echo "$taskdata" | jq .

#curl --insecure --header "$type_header" --header "$auth_header" --request POST "$uri" --data "$taskdata"
#url=$(${curl} --header "$type_header" --header "$auth_header" --request POST "$uri" --data "$taskdata" | jq --raw-output .job.id)
url=$($curl --header "$type_header" --header "$auth_header" --request POST "$uri" --data "$taskdata" | jq --raw-output .job.id)

# folgendes pollen bis .state == finished
echo '# RESPONSE 1'

$curl --header "$type_header" --header "$auth_header" --request GET "${url}" | jq --raw-output .state

echo '# RESPONSE 2'

${curl} --request GET "${url}" | jq --raw-output .state

# wenn .state == finished, dann ausgabe vom task auslesen
echo '# RESPONSE 3'
#${curl} --header "$type_header" --header "$auth_header" "${url}/events" | jq '.items | .[] | select(.type=="node_finished").details.detail.status' --raw-output
${curl} --header "$type_header" --header "$auth_header" "${url}/events" | jq .

# response is something like this:
# {
#  "next-events": {
#    "id": "https://pe.local:8143/orchestrator/v1/jobs/6/events?start=19",
#    "event": "19"
#  },
#  "items": [
#    {
#      "type": "node_running",
#      "timestamp": "2025-02-26T08:23:04Z",
#      "id": "16",
#      "details": {
#        "node": "pe.local",
#        "detail": {},
#        "transport": "pcp"
#      }
#    },
#    {
#      "type": "node_finished",
#      "timestamp": "2025-02-26T08:23:04Z",
#      "id": "17",
#      "details": {
#        "node": "pe.tim.betadots.training",
#        "detail": {
#          "status": "MainPID=0,LoadState=loaded,ActiveState=inactive",
#          "enabled": "static"
#        },
#        "transport": "pcp"
#      }
#    },
#    {
#      "type": "job_finished",
#      "timestamp": "2025-02-26T08:23:04Z",
#      "id": "18",
#      "details": {
#        "state": "finished"
#      }
#    }
#  ]
#}

# important is items -> type->node_finished->details->detail->status. has to be "MainPID=0,LoadState=loaded,ActiveState=inactive"
