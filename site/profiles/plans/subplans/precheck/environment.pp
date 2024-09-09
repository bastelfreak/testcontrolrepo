#
# @summary ensures that the used environment is configured properly everywhere
#
# @param primary_host the FQDN/common name of the primary
# @param runs_via_bolt configure if this plan and all subplans/tasks are executed via bolt or PE. Some PE functions have different signatures
#
# @api private
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::subplans::precheck::environment (
  Peadm::SingleTargetSpec $primary_host,
  Boolean $runs_via_bolt = true,
) {
  # check the used environment from the last run
  # check if that's set in the puppet.conf
  # check if that's set in the pe.conf or user_data.conf
  # Update https://www.puppet.com/docs/pe/2021.7/upgrade_pe#update_environment
  if $runs_via_bolt {
    $main  = { 'action' => 'get', 'setting' => 'environment', 'section' => 'main', '_run_as' => 'root' }
    $agent = { 'action' => 'get', 'setting' => 'environment', 'section' => 'agent', '_run_as' => 'root' }
  } else {
    $main  = { 'action' => 'get', 'setting' => 'environment', 'section' => 'main' }
    $agent = { 'action' => 'get', 'setting' => 'environment', 'section' => 'agent' }
  }

  $main_results = run_task('puppet_conf', $primary_host, 'description', $main)
  $main_env = $main_results.results[0].value['status']

  $agent_results = run_task('puppet_conf', $primary_host, 'description', $agent)
  $agent_env = $agent_results.results[0].value['status']

  $puppetdb_results = puppetdb_query("nodes[catalog_environment]{ certname = \"${primary_host}\"}")
  $puppetdb_env = $puppetdb_results[0]['catalog_environment']
  out::message("configured environments: main section: ${main_env}; agent section: ${agent_env}; last used env: ${puppetdb_env}")

  # the environment used in puppet.conf or the default env
  $conf_env = if $agent_env != $main_env {
    out::message("'environment' set in agent section in puppet.conf: ${agent_env}")
    $agent_env
  } else {
    out::message("Using 'environment' from main (default is production if not set at all): ${main_env}")
    $main_env
  }

  if $conf_env != $puppetdb_env {
    fail("The ENC provided environment '${puppetdb_env}' is not set in puppet.conf (${conf_env})")
  }
}
