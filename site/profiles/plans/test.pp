plan profiles::test {
  $primary_host = 'pe.tim.betadots.training'

  $main  = {'action' => 'get', 'value' => 'environment', 'section' => 'main'}
  $agent = {'action' => 'get', 'value' => 'environment', 'section' => 'agent'}

  $foo = run_task('puppet_conf', $main, 'targets' => $primary_host, '_run_as' => 'root')

  out::message($foo)
}
