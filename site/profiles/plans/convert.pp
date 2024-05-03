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

  $result = run_plan('pe_status_check::agent_state_summary', '_catch_errors' => true)

  $table = format::table(
    {
      title => 'Puppet Agent states',
      head  => ['status check', 'Nodes'],
      rows  => $result.map |$key, $data| { [$key, [$data].flatten.join(', ')]},
    }
  )
  out::message($table)
  # ToDo: Can we get the bolt project path?
  file::write('/opt/peadmmig/agent_state_summary.json', $result.stdlib::to_json_pretty)
}
