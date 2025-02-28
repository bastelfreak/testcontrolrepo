#
# @summary calls peadm::upgrade + sanity checks. supposed to be executed via systemd unit
#
# @param primary_host the FQDN/common name of the primary
# @param version always points to the latest LTS
# @param pe_installer_source optional URL to the PE builds, can point to a webdir or absolute URL
# @param download_mode if peadm should download the installer and upload to targets, or if targets should download it on their own
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::upgrade (
  Peadm::SingleTargetSpec $primary_host,
  Peadm::Pe_version $version = '2021.7.10',
  Optional[Stdlib::HTTPSUrl] $pe_installer_source = undef,
  Enum['direct','bolthost']  $download_mode = 'bolthost',
) {
  # In their infinite wisdom, the Puppet security team (a single person that doesn't know the product),
  # decided that it's insecure when PEADM can download the installer archive from an internal mirror
  # Because of that, we need to download the installer before doing the upgrade.
  # The peadm::upgrade plan will check if the archive is available locally and then won't try to download it from AWS
  # Of course AWS is way more trustworthy than a local mirror
  # * https://github.com/puppetlabs/puppetlabs-peadm/pull/465/
  # * https://github.com/puppetlabs/puppetlabs-peadm/pull/524/
  if $pe_installer_source {
    # custom URL ends with /, so we assume it's a webdir with the original installer
    $pe_tarball_source = if $pe_installer_source[-1] == '/' {
      $platform          = run_task('peadm::precheck', $primary_host).first['platform']
      $pe_tarball_name   = "puppet-enterprise-${version}-${platform}.tar.gz"
      out::message("pe_installer_source is a relative URL, downloading: ${pe_installer_source}${pe_tarball_name}")
      "${pe_installer_source}${pe_tarball_name}"
    } else {
      out::message("pe_installer_source is an absolute URL: ${pe_installer_source}")
      $pe_installer_source
    }
    # Now download the archive
    if $download_mode == 'bolthost' {
      $upload_tarball_path = "/tmp/${pe_tarball_name}"
      run_plan('peadm::util::retrieve_and_upload', $primary_host,
        source      => $pe_tarball_source,
        local_path  => "/tmp/${pe_tarball_name}",
        upload_path => $upload_tarball_path,
      )
    } else {
      run_task('peadm::download', $primary_host,
        source => $pe_tarball_source,
        path   => $upload_tarball_path,
      )
    }
  } else {
    out::message('pe_installer_source not set, PE installer archive will be downloaded from the PEADM default')
  }
  run_plan('profiles::subplans::precheck', { 'primary_host' => $primary_host })

  $upgrade_params = {
    'primary_host' => $primary_host,
    'version' => $version,
    'permit_unsafe_versions' => true ,
    '_run_as' => 'root',
  }.delete_undef_values
  run_plan('peadm::upgrade', $upgrade_params)

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
