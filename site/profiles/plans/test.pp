plan profiles::test {
  $primary_host = 'pe.tim.betadots.training'

  $main  = {'action' => 'get', 'setting' => 'environment', 'section' => 'main', '_run_as' => 'root'}
  $agent = {'action' => 'get', 'setting' => 'environment', 'section' => 'agent', '_run_as' => 'root'}

  $main_results = run_task('puppet_conf', $primary_host, 'description', $main)
  $main_env = $main_results.results[0].value['status']

  #out::message($foo.results[0].value['status'])

  $agent_results = run_task('puppet_conf', $primary_host, 'description', $agent)
  $agent_env = $agent_results.results[0].value['status']

  $puppetdb_results = puppetdb_query("nodes[catalog_environment]{ certname = \"${primary_host}\"}")
  $puppetdb_env = puppetdb_results[0]['catalog_environment']
  out::message("configured environments: main section: ${main_env}; agent section: ${agent_env}; last used env: ${puppetdb_env}")
}
