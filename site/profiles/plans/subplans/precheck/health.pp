#
# @summary ensures that the used environment is configured properly everywhere
#
# @param primary_host the FQDN/common name of the primary
# @param runs_via_bolt configure if this plan and all subplans/tasks are executed via bolt or PE. Some PE functions have different signatures
#
# @api private
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::subplans::precheck::health (
  Peadm::SingleTargetSpec $primary_host,
  Boolean $runs_via_bolt = true,
) {
  # Todo: How do we handle errors resulting from run_plan? Do we always use _catch_errors and then call fail()/fail_plan()?
  # {
  #   "noop": [ ],
  #   "corrective_changes": [ ],
  #   "used_cached_catalog": [ ],
  #   "failed": [ ],
  #   "changed": [ ],
  #   "unresponsive": [ ],
  #   "responsive": [ "primary.lab.local" ],
  #   "unhealthy": [ ],
  #   "unhealthy_counter": 0,
  #   "healthy": [ "primary.lab.local" ],
  #   "healthy_counter": 1,
  #   "total_counter": 1
  # }
  $states = run_plan('pe_status_check::agent_state_summary', { 'log_healthy_nodes' => true })

  # YYYY-MM-DD
  $date = Timestamp().strftime('%Y-%m-%d')
  # ToDo: Can we get the bolt project path?
  # Jeffrey Clark wants to propose a PR to extlib
  $state_path = "/opt/peadmmig/agent_state_summary__${date}.json"
  out::verbose("profiles::subplans::precheck: writing ${state_path}")
  file::write("/opt/peadmmig/agent_state_summary_${date}.json", $states.stdlib::to_json_pretty)

  # ToDo: fail() vs fail_plan()?
  if $states['unhealthy_counter'] > 0 {
    # output node status if we are unhealthy, otherwise keep stdout clean
    $states_table = format::table(
      {
        title => 'Puppet Agent states',
        head  => ['status check', 'Nodes'],
        rows  => $states.map |$key, $data| { [$key, [$data].flatten.join(', ')] },
      }
    )
    out::message($states_table)
    fail("we have ${$states['unhealthy_counter']} unhealthy nodes")
  }

  # {
  #   "primary": [ "primary.lab.local" ],
  #   "legacy_primary": [ ],
  #   "replica": [ ],
  #   "compiler": [ ],
  #   "legacy_compiler": [ ],
  #   "postgres": [ ]
  # }
  $roles = run_plan('pe_status_check::infra_role_summary')
  $summary_path = "/opt/peadmmig/infra_role_summary__${date}.json"
  out::verbose("profiles::subplans::precheck: writing ${summary_path}")
  file::write($summary_path, $roles.stdlib::to_json_pretty)
  $summary_table = format::table(
    {
      title => 'PE infrastructure role summary',
      head  => ['Roles', 'Nodes'],
      rows  => $roles.map |$key, $data| { [$key, $data.join(', ')] },
    }
  )

  if $roles['primary'].count != 1 {
    out::message($summary_table)
    fail("we identified not exactly one primary, but: ${roles['primary'].join(', ')}.")
  }
  ($roles - 'primary').each |$role, $nodes| {
    unless $nodes.empty {
      out::message($summary_table)
      fail("role: ${role}: We found ${nodes.join(', ')}. We only support a single primary")
    }
  }

  # Get facts from all nodes for various checks
  # ToDo: this calls the facts task and that dumps all facts to stdout which is really stupid
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
  #   { "value": "6.28.0" },
  #   { "value": "6.24.0" }
  # ]
  $aio_agent_versions = puppetdb_query('facts[value]{ name = "aio_agent_version" group by value}')
  if $aio_agent_versions.count > 1 {
    $versionstring = $aio_agent_versions.map |$version| { $version['value'] }.join(', ')
    fail("We have a version missmatch, we found the following puppet agent versions: ${$versionstring}. All nodes need to have the same version")
  }
}
