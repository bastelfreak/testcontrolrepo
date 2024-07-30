plan profiles::test {
  $primary_host = 'pe.tim.betadots.training'

  $main  = {'action'                              => 'get', 'value' => 'environment', 'section' => 'main', '_run_as' => 'root'}
  $agent = {'action'                              => 'get', 'value' => 'environment', 'section' => 'agent', '_run_as' => 'root'}

  $foo = run_task('puppet_conf', $primary_host, 'description', $main)

  out::message($foo)
}
