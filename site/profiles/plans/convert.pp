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

  # Todo: How do we handle errors resulting from run_plan? Do we always use _catch_errors and then call fail()/fail_plan()?
  # ToDo: Repeat for pe_status_check::infra_role_summary
  $result = run_plan('pe_status_check::agent_state_summary')

  $table = format::table(
    {
      title => 'Puppet Agent states',
      head  => ['status check', 'Nodes'],
      rows  => $result.map |$key, $data| { [$key, [$data].flatten.join(', ')]},
    }
  )
  # ToDo: Can we get the bolt project path?
  file::write('/opt/peadmmig/agent_state_summary_before_convert.json', $result.stdlib::to_json_pretty)

  # ToDo: fail() vs fail_plan()?
  if $result['unhealthy_counter'] > 0 {
    # output node status if we are unhealthy, otherwise keep stdout clean
    out::message($table)
    # ToDo: does systemctl status indicate successful vs failed bolt rns?
    fail("we have ${$result['unhealthy_counter']} unhealthy nodes")
  }

  # Get facts from all nodes for various checks
  run_plan('facts', 'targets' => $primary_host)

  # ensure we're on the suiteable PE version
  $pe_build = get_target($primary_host).facts['pe_build']
  unless $pe_build {
    fail("fact `pe_build` is undef on ${primary_host}")
  }

  # 2019.8.1 is the oldest supported version according to
  # https://github.com/puppetlabs/puppetlabs-peadm?tab=readme-ov-file#puppet-enterprise-administration-module-peadm
  if versioncmp('2019.8.1', $pe_build) == 1 {
    fail("we are on PE version ${pe_build}, minimum version is 2019.8.1")
  }

  # check if all agents are on the same puppet agent version
  # [
  #   {
  #     "value": "6.28.0"
  #   },
  #   {
  #     "value": "6.24.0"
  #   }
  # ]
  $aio_agent_versions = puppetdb_query('facts[value]{ name = "aio_agent_version" group by value}')
  if $aio_agent_versions.count > 1 {
    $versionstring = $aio_agent_versions.map |$version| { $version['value'] }.join(', ')
    fail("We have a version missmatch, we found the following puppet agent versions: ${$versionstring}. All nodes need to have the same version")
  }
}
