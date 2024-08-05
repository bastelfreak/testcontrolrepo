#
# @summary calls peadm::upgrade + sanity checks. supposed to be executed via systemd unit
#
# @param primary_host the FQDN/common name of the primary
# @param version always points to the latest LTS
# @param pe_installer_source optional URL to the PE builds, can point to a webdir or absolute URL
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::upgrade (
  Peadm::SingleTargetSpec $primary_host,
  Peadm::Pe_version $version = '2021.7.8',
  Optional[Stdlib::HTTPSUrl] $pe_installer_source = undef,
) {
  run_plan('profiles::subplans::precheck', { 'primary_host' => $primary_host })

  run_plan('peadm::upgrade', { 'primary_host' => $primary_host, 'version' => $version, 'pe_installer_source' => $pe_installer_source, '_run_as' => 'root' }.delete_undef_values)

  # peadm::upgrade doesn't do a final puppet run without changed resources
  # To have a clean report, we trigger a puppet run here
  # we  run it twice, in case we've a raise condition with an already running puppet agent
  $result = run_task('peadm::puppet_runonce', $primary_host, '_run_as' => 'root', '_catch_errors' => true)
  # ok is true if the task was successful on all targets
  unless $result.ok {
    out::message("Final peadm::puppet_runonce failed with: ${result}")
    out::message('Trying another puppet run')
    run_task('peadm::puppet_runonce', $primary_host, '_run_as' => 'root')
  }
  # cleanup diskspace by removing old packages
  # this will remove everything except `current` from
  # * /opt/puppetlabs/server/data/packages/public
  # * /opt/puppetlabs/server/data/staging
  run_plan('enterprise_tasks::remove_old_pe_packages', { 'primary' => $primary_host, 'force' => true, '_run_as' => 'root', })
}
