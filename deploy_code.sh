#!/bin/bash

type_header='Content-Type: application/json'
auth_header="X-Authentication: $(puppet-access show)"
cacert="$(puppet config print localcacert)"
uri="https://$(puppet config print server):8170/code-manager/v1/deploys"

data='{"environments": ["peadm"], "wait": true}'

curl --header "$type_header" --header "$auth_header" --cacert "$cacert" --request POST "$uri" --data "$data" --silent | jq .
