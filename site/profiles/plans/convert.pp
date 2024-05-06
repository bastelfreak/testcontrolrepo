#
# @summary calls peadm::convert + sanity checks. supposed to be executed via systemd unit
#
# @param primary_host the FQDN/common name of the primary, passed to peadm::convert
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::convert (
  Peadm::SingleTargetSpec $primary_host,
) {

  run_plan('profiles::subplans::precheck', {'primary_host' => $primary_host})

  # peadm::convert does two more sanity checks:
  #   - do we have the correct bolt version
  #   - are all nodes reachable
  # ToDo: download the correct pe installer and provide that to the plan <- for peadm::upgrade
  run_plan('peadm::convert', { 'primary_host' => $primary_host}, '_run_as' => 'root')
}
