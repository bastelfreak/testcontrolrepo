function profiles::environment (Peadm::SingleTargetSpec $primary_host) >> Hash {
  $main  = {'action' => 'get', 'setting' => 'environment', 'section' => 'main', '_run_as' => 'root'}
  $agent = {'action' => 'get', 'setting' => 'environment', 'section' => 'agent', '_run_as' => 'root'}

  $main_results = run_task('puppet_conf', $primary_host, 'description', $main)
  $main_env = $main_results.results[0].value['status']

  $agent_results = run_task('puppet_conf', $primary_host, 'description', $agent)
  $agent_env = $agent_results.results[0].value['status']

  $puppetdb_results = puppetdb_query("nodes[catalog_environment]{ certname = \"${primary_host}\"}")
  $puppetdb_env = $puppetdb_results[0]['catalog_environment']
  out::message("configured environments: main section: ${main_env}; agent section: ${agent_env}; last used env: ${puppetdb_env}")

  # the environment used in puppet.conf or the default env
  $conf_env = if $agent_env != $main_env {
    #out::message("'environment' set in agent section in puppet.conf: ${agent_env}")
    $agent_env
  } else {
    #out::message("Using 'environment' from main (default is production if not set at all): ${main_env}")
    $main_env
  }

  $config_is_correct = if $conf_env != $puppetdb_env {
    # fail("The ENC provided environment '${puppetdb_env}' is not set in puppet.conf (${conf_env})")
    #out::message("The ENC provided environment '${puppetdb_env}' is not set in puppet.conf (${conf_env})")
    false
  } else {
    true
  }
  $return = { 'config_is_correct' => $config_is_correct, 'correct_env' => $puppetdb_env, }
  $return
}
