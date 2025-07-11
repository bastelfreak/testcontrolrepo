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

#   puppet task run profile::recertify_node_yolo.sh --params '{"my_function":"valid_certname"}' --node PRIMARY
  $nodes.each|$single_node|{
    $result=run_task(
      'profile::recertify_node_yolo',
      $primary,
      myfunction => 'valid_certname', singlenode => $single_node, nodelist => "nonEmpty", _catch_errors => true
    )
    unless $result.ok {
      fail("Node ${single_node} not known to Primary. Result=${result.error_set.names}")
    }
  }
  $node_list.each|$single_node|{
    $result=run_task(
      'profile::recertify_node_yolo',
      $primary,
      myfunction => 'precheck_p2a_server', singlenode => $single_node, nodelist => "nonEmpty", _catch_errors => true
    )
    unless $result.ok {
      fail("Node ${single_node} has no replacement certificate signing request in gitlab Result=${result.error_set.names}")
    }
  }
  $node_list.each|$single_node|{
    $result=run_task(
      'profile::recertify_node_yolo',
      $single_node,
      myfunction => 'download_p2a_csr', singlenode => $single_node, nodelist => "nonEmpty", debug => "/bin/true", _catch_errors => true
    )
    unless $result.ok {
      fail("Node ${single_node}; precondition not met, either on of: (1) you tried to recertify puppet master, (2) nodes PXP agent is not running, (3) node could not retrieve csr_attributes.yaml, aborting ;Result=${result.error_set.names}")
    }
  }

  $node_list.each|$single_node|{
    $release=run_task(
      'profile::recertify_node_yolo',
      $primary,
      myfunction => 'release_node', singlenode => $single_node, nodelist => "nonEmpty", _catch_errors => true
    )
    $rmdirssl=run_task(
      'profile::recertify_node_yolo',
      $single_node,
      myfunction => 'rmdir_ssl', singlenode => $single_node, nodelist => "nonEmpty", _catch_errors => true
    )
    $agentrun=run_task(
      'profile::recertify_node_yolo',
      $single_node,
      myfunction => 'agent_run', singlenode => $single_node, nodelist => "nonEmpty", _catch_errors => true
    )
    unless $release.ok {
      fail("Node ${single_node} unknown error. Releasing and re-registering failed.")
    }
    unless $rmdirssl.ok {
      fail("Node ${single_node} unknown error. Releasing and re-registering failed.")
    }
    unless $agentrun.ok {
      fail("Node ${single_node} unknown error. Releasing and re-registering failed.")
    }
  }
}
