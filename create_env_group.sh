#!/bin/bash

set -e

##
# creates the environment node group `peadm` and assigns one class to it
# The environment needs to exist
##

# get id for `all environments` node group
auth_header="X-Authentication: $(puppet-access show)"
cacert="$(puppet config print localcacert)"
uri="https://$(puppet config print server):4433/classifier-api/v1/groups"
id=$(curl --cacert "$cacert" --header "$auth_header" "$uri" --silent | jq --raw-output '.[] | select(.name=="All Environments").id')

# create new environment node group
data="
{
  \"name\": \"peadm\",
  \"parent\": \"$id\",
  \"environment\": \"peadm\",
  \"environment_trumps\": true,
  \"description\": \"Test environment for PEADM upgrades\",
  \"classes\": {
  \"profiles::cleanup\": {}
  }
}
"
type_header='Content-Type: application/json'
curl --cacert "$cacert" --header "$auth_header" --header "$type_header" "$uri" --data "$data"
