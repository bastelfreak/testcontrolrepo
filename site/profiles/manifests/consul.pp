class profiles::consul {
  class { 'consul':
    install_method  => 'package',
    manage_repo     => $facts['os']['name'] != 'Archlinux',
    init_style      => 'unmanaged',
    manage_data_dir => true,
    manage_group    => false,
    manage_user     => false,
    config_dir      => '/etc/consul.d/',
    config_hash     => {
      'server'    => true,
      'bind_addr' => '[::]',
    },
  }
  systemd::dropin_file { 'foo.conf':
    unit           => 'consul.service',
    content        => "[Unit]\nConditionFileNotEmpty=\nConditionFileNotEmpty=/etc/consul.d/config.json",
    notify_service => true,
  }
}
