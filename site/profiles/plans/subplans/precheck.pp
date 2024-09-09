#
# @summary validates if an environment is healthy so we can do modifications or upgrades
#
# @param primary_host the FQDN/common name of the primary
# @param validate_environment if we should ensure that the environment is configured properly everywhere
# @param validate_health check if all agents are working and the environment is healthy
#
# @api private
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::subplans::precheck (
  Peadm::SingleTargetSpec $primary_host,
  Boolean $validate_environment = true,
  Boolean $validate_health = true,
) {
  # To have a clean report, we trigger a puppet run here
  # we  run it twice, in case we've a raise condition with an already running puppet agent
  $result = run_task('peadm::puppet_runonce', $primary_host, '_run_as' => 'root', '_catch_errors' => true)
  # ok is true if the task was successful on all targets
  unless $result.ok {
    out::message("Final peadm::puppet_runonce failed with: ${result}")
    out::message('Trying another puppet run')
    run_task('peadm::puppet_runonce', $primary_host, '_run_as' => 'root')
  }

  # check if the used environment is configured everywhere so agents don't flap by accident
  # important when we do PE/Puppet updates
  if $validate_environment {
    run_plan('profiles::subplans::precheck::environment', {'primary_host' => $primary_host})
  }


  # check if all agents are working and the environment is healthy
  if $validate_health {
    run_plan('profiles::subplans::precheck::health', {'primary_host' => $primary_host})
  }
}
