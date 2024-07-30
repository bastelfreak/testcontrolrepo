#
# @summary validates if an environment is healthy so we can do modifications or upgrades
#
# @param primary_host the FQDN/common name of the primary
#
# @api private
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::subplans::precheck (
  Peadm::SingleTargetSpec $primary_host,
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

  # check the used environment from the last run
  # check if that's set in the puppet.conf
  # check if that's set in the pe.conf or user_data.conf
  # Update https://www.puppet.com/docs/pe/2021.7/upgrade_pe#update_environment
  $main  = {'action' => 'get', 'setting' => 'environment', 'section' => 'main', '_run_as' => 'root'}
  $agent = {'action' => 'get', 'setting' => 'environment', 'section' => 'agent', '_run_as' => 'root'}

  $main_results = run_task('puppet_conf', $primary_host, 'description', $main)
  $main_env = $main_results.results[0].value['status']

  $agent_results = run_task('puppet_conf', $primary_host, 'description', $agent)
  $agent_env = $agent_results.results[0].value['status']

  $puppetdb_results = puppetdb_query("nodes[catalog_environment]{ certname = \"${primary_host}\"}")
  $puppetdb_env = $puppetdb_results[0]['catalog_environment']
  out::message("configured environments: main section: ${main_env}; agent section: ${agent_env}; last used env: ${puppetdb_env}")

  # the environment used in puppet.conf or the default env
  $conf_env = if $agent_env != $main_env {
    out::message("'environment' set in agent section in puppet.conf: ${agent_env}")
    $agent_env
  } else {
    out::message("Using 'environment' from main (default is production if not set at all): ${main_env}")
    $main_env
  }

  if $conf_env != $puppetdb_env {
    fail("The ENC provided environment '${puppetdb_env}' is not set in puppet.conf (${conf_env})")
  }

  # Todo: How do we handle errors resulting from run_plan? Do we always use _catch_errors and then call fail()/fail_plan()?
  # ToDo: Repeat for pe_status_check::infra_role_summary
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
