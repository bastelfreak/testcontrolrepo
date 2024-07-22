#
# @summary calls peadm::upgrade + sanity checks. supposed to be executed via systemd unit
#
# @param primary_host the FQDN/common name of the primary, passed to peadm::convert
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::upgradeto2021 (
  Peadm::SingleTargetSpec $primary_host,
  Peadm::Pe_version $version = '2021.7.8',
) {
  run_plan('profiles::subplans::precheck', { 'primary_host' => $primary_host })

  # peadm::convert does two more sanity checks:
  #   - do we have the correct bolt version
  #   - are all nodes reachable
  # ToDo: download the correct pe installer and provide that to the plan <- for peadm::upgrade
  run_plan('peadm::upgrade', { 'primary_host' => $primary_host, 'version' => $version, '_run_as' => 'root' })

  # peadm::upgrade doesn't do a final puppet run without changed resources
  # To have a clean report, we trigger a puppet run here
  run_task('peadm::puppet_runonce', $primary_host, '_run_as' => 'root')
}
