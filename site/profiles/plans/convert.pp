#
# @summary calls peadm::convert + sanity checks. supposed to be executed via systemd unit
#
# @param primary_host the FQDN/common name of the primary
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::convert (
  Peadm::SingleTargetSpec $primary_host,
) {

  $result = run_plan('pe_status_check::agent_state_summary', '_catch_errors' => true)
  out::message($result)
}
