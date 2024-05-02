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
  file { "${project_path}/bolt-project.yaml":
    ensure  => 'file',
    owner   => $owner,
    group   => $group,
    content => { 'analytics' => false, 'name' => $project, }.stdlib::to_yaml,
  }

  $data = { 'project' => $project, 'user'=> $owner, 'group' => $group, 'project_path' => $project_path, 'environment' => 'peadm' }
  systemd::unit_file { "${project}@.service":
    content => epp("${module_name}/project.service.epp", $data),
  }
}
