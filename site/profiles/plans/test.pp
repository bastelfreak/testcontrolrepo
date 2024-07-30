plan profiles::test {
  $primary_host = 'pe.tim.betadots.training'

  $main  = {'action' => 'get', 'setting' => 'environment', 'section' => 'main', '_run_as' => 'root'}
  $agent = {'action' => 'get', 'setting' => 'environment', 'section' => 'agent', '_run_as' => 'root'}

  $foo = run_task('puppet_conf', $primary_host, 'description', $main)

  out::message($foo.results[0])
}
