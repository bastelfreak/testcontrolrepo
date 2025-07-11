#
# @summary Plan zum Austausch der csr_attribute auf einer Liste von Nodes
# @param node_list Puppet-FQDNs of Nodes to be recertified.
#
plan profile::p2a_recertify(
  TargetSpec $primary="puppet.local",
  Array[String[1]] $node_list,
){
  # since node_list isn't a list of FQDNs, but maybe a list of subtrings of FQDN
  # so we have to iterate on them and do a PQL query for each element
  # PQL has an `in` operator, but that doesn't work for substring matching
  # https://www.puppet.com/docs/puppetdb/8/api/query/v4/pql.html#array-match-in
  $nodes = $node_list.map |$substring| {
    $nodes = puppetdb_query("inventory[certname] { certname ~ '${substring}' }").map |$node| { $node['certname'] }
  }.flatten.unique

  out::message("Found following nodes: ${nodes.join(' ')}")

  $nodes.each |$node| {
    $data_valid_certname = {myfunction => 'valid_certname', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true}
    $valid_certname = run_task('profile::recertify_node_yolo', $primary, "valid_certname for ${node}"), $data_valid_certname)
    unless $valid_certname.ok {
      warning("Node ${node} not known to Primary. Result=${valid_certname.error_set.names}")
      next()
    }

    $data_precheck_p2a_server = {myfunction => 'precheck_p2a_server', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true}
    $precheck_p2a_server = run_task('profile::recertify_node_yolo', $primary, "precheck_p2a_server for ${node}", $data_precheck_p2a_server)
    unless $precheck_p2a_server.ok {
      warning("Node ${node} has no replacement certificate signing request in gitlab Result=${precheck_p2a_server.error_set.names}")
      next()
    }

    $data_download_p2a_csr = {myfunction => 'download_p2a_csr', singlenode => $node, nodelist => "nonEmpty", debug => "/bin/true", _catch_errors => true}
    $download_p2a_csr = run_task('profile::recertify_node_yolo', $node, "download_p2a_csr for ${node}", $data_download_p2a_csr)
    unless $download_p2a_csr.ok {
      warning("Node ${node}; precondition not met, either on of: (1) you tried to recertify puppet master, (2) nodes PXP agent is not running, (3) node could not retrieve csr_attributes.yaml, aborting ;Result=${download_p2a_csr.error_set.names}")
      next()
    }

    $data_release_node = {myfunction => 'release_node', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true}
    $release_node = run_task('profile::recertify_node_yolo', $primary, "release_node for ${node}", $data_release_node)
    unless $release_node.ok {
      warning("Node ${node} unknown error. Releasing and re-registering failed.")
      next()
    }

    $data_rmdir_ssl = {myfunction => 'rmdir_ssl', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true}
    $rmdir_ssl = run_task('profile::recertify_node_yolo', $node, "rmdir_ssl for ${node}", $data_rmdir_ssl)
    unless $rmdir_ssl.ok {
      warning("Node ${node} unknown error. Releasing and re-registering failed.")
      next()
    }

    $data_agentrun = {myfunction => 'agent_run', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true}
    $agentrun = run_task('profile::recertify_node_yolo', $node, "agent_run for ${node}", $data_agentrun)
    unless $agentrun.ok {
      warning("Node ${node} unknown error. Releasing and re-registering failed.")
    }
  }
}
