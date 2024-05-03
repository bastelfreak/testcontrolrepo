#
# @summary creates required files for a bolt project. Will create one oneshot service for each plan
#
# @param basepath
# @param project
#
# @author Tim Meusel <tim@bastelfreak.de>
#
define bolt::project (
  Stdlib::Absolutepath $basepath = '/opt/',
  String[1] $project = $name,
  String[1] $owner = $project,
  String[1] $group = $project,
  Boolean $manage_user = true,
  Array[String[1]] $plans = [],
  String[1] $environment = 'peadm',
  Array[Stdlib::Absolutepath] $modulepaths = ["/etc/puppetlabs/code/environments/${environment}/modules", "/etc/puppetlabs/code/environments/${environment}/site",],
) {
  # installs bolt
  require bolt

  $project_path = "${basepath}${name}"
  if $manage_user {
    user { $project:
      ensure         => 'present',
      managehome     => true,
      purge_ssh_keys => true,
      system         => true,
      home           => $project_path,
      gid            => $project,
      groups         => ['pe-puppet'], # required to read codedir
      shell          => '/sbin/nologin',
      comment        => 'user to run bolt plans',
    }
    group { $project:
      ensure => 'present',
      system => true,
    }
  }
  file { $project_path:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
  }

  $bolt_project = { 'analytics' => false, 'name' => $project, 'modulepath' => $modulepaths, 'stream' => true }.stdlib::to_yaml

  file { "${project_path}/bolt-project.yaml":
    ensure  => 'file',
    owner   => $owner,
    group   => $group,
    content => $bolt_project,
  }

  $inventory = { 'groups' => [{ 'name' => 'primary', 'targets' => [{ 'name' => $facts['networking']['fqdn'], 'uri' => 'local://localhost' }] }] }.stdlib::to_yaml

  file { "${project_path}/inventory.yaml":
    ensure  => 'file',
    owner   => $owner,
    group   => $group,
    content => $inventory,
  }

  $data = { 'project' => $project, 'user'=> $owner, 'group' => $group, 'project_path' => $project_path, 'environment' => 'peadm' }

  systemd::unit_file { "${project}@.service":
    content => epp("${module_name}/project.service.epp", $data),
  }
}
