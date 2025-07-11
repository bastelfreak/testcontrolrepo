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

  $nodes.each |$node| {
    $valid_certname=run_task('profile::recertify_node_yolo', $primary, myfunction => 'valid_certname', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true)
    unless $valid_certname.ok {
      warn("Node ${node} not known to Primary. Result=${valid_certname.error_set.names}")
      next()
    }

    $precheck_p2a_server=run_task('profile::recertify_node_yolo', $primary, myfunction => 'precheck_p2a_server', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true)
    unless $precheck_p2a_server.ok {
      warn("Node ${node} has no replacement certificate signing request in gitlab Result=${precheck_p2a_server.error_set.names}")
      next()
    }

    $download_p2a_csr=run_task('profile::recertify_node_yolo', $node, myfunction => 'download_p2a_csr', singlenode => $node, nodelist => "nonEmpty", debug => "/bin/true", _catch_errors => true)
    unless $download_p2a_csr.ok {
      warn("Node ${node}; precondition not met, either on of: (1) you tried to recertify puppet master, (2) nodes PXP agent is not running, (3) node could not retrieve csr_attributes.yaml, aborting ;Result=${download_p2a_csr.error_set.names}")
      next()
    }

    $release_node=run_task('profile::recertify_node_yolo', $primary, myfunction => 'release_node', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true)
    unless $release_node.ok {
      fail("Node ${node} unknown error. Releasing and re-registering failed.")
      next()
    }

    $rmdir_ssl=run_task('profile::recertify_node_yolo', $node, myfunction => 'rmdir_ssl', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true)
    unless $rmdir_ssl.ok {
      fail("Node ${node} unknown error. Releasing and re-registering failed.")
    }

    $agentrun=run_task('profile::recertify_node_yolo', $node, myfunction => 'agent_run', singlenode => $node, nodelist => "nonEmpty", _catch_errors => true)
    unless $agentrun.ok {
      fail("Node ${node} unknown error. Releasing and re-registering failed.")
    }
  }
}
