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
    "action": "start",
    "name": "peadmmig@profiles::convert.service" },
  "task": "service::linux",
  "environment": "peadm"
}'

echo '# PAYLOAD'
echo "$taskdata" | jq .

${curl} --header "$type_header" --header "$auth_header" --request POST "$uri" --data "$taskdata" | jq .
