#
# @summary reads the r10k deployment information and returns it as json
#
function profiles::r10k_deploy >> Hash {
  # puppet_environmentpath comes from stdlib
  $path = [$facts['puppet_environmentpath'], $server_facts['environment'], '.r10k-deploy.json']
  loadjson($path.join('/'))
}
