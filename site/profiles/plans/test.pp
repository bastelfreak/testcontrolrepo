plan profiles::test {
  $primary_host = 'pe.tim.betadots.training'

  $main  = {'action'                              => 'get', 'value' => 'environment', 'section' => 'main', '_run_as' => 'root'}
  $agent = {'action'                              => 'get', 'value' => 'environment', 'section' => 'agent', '_run_as' => 'root'}

  $foo = run_task('puppet_conf', 'targets' => $primary_host, 'args' => $main)

  out::message($foo)
}
