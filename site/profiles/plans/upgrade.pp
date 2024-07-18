#
# @summary calls peadm::upgrade + sanity checks. supposed to be executed via systemd unit
#
# @param primary_host the FQDN/common name of the primary, passed to peadm::convert
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::upgrade (
  Peadm::SingleTargetSpec $primary_host,
  Peadm::Pe_version $version = '2021.7.8',
) {
  run_plan('profiles::subplans::precheck', { 'primary_host' => $primary_host })

  # peadm::convert does two more sanity checks:
  #   - do we have the correct bolt version
  #   - are all nodes reachable
  # ToDo: download the correct pe installer and provide that to the plan <- for peadm::upgrade
  run_plan('peadm::upgrade', { 'primary_host' => $primary_host, 'version' => $version, '_run_as' => 'root' })
}
