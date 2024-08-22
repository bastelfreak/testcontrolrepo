#
# @summary collect information about a configured vs used environment
#
# @param node the node we check, usually the one that executes this function
#
# @api private
#
# @see profiles::validate_env
#
# @author Tim Meusel <tim@bastelfreak.de>
#
function profiles::validate_env_puppet (
  Stdlib::Fqdn $node = $trusted['certname'],
) >> Hash {
  # ToDo: If $node != localhost, we need to get facts from PuppetDB
  if fact('extlib__puppet_config.agent.environment') {
    $config_env = $facts['extlib__puppet_config']['agent']['environment']
  } else {
    fail('puppet/extlib 7.2.0 or newer is required for the extlib__puppet_config.agent.environment fact')
  }
  $puppetdb_results = puppetdb_query("nodes[catalog_environment]{ certname = \"${node}\"}")
  $puppetdb_env = $puppetdb_results[0]['catalog_environment']
  $config_is_correct = $config_env == $puppetdb_env
  $return = { 'config_is_correct' => $config_is_correct, 'correct_env' => $puppetdb_env, }
  $return
}
