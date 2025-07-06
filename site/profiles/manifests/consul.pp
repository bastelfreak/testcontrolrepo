class profiles::consul {
  $nodes = [
    'server1.tim.betadots.training',
    'server2.tim.betadots.training',
    'server3.tim.betadots.training',
  ]
  class { 'consul':
    install_method  => 'package',
    manage_repo     => $facts['os']['name'] != 'Archlinux',
    init_style      => 'unmanaged',
    manage_data_dir => true,
    manage_group    => false,
    manage_user     => false,
    config_dir      => '/etc/consul.d/',
    pretty_config        => true,
    pretty_config_indent => 2,
    config_hash     => {
      'server'    => true,
      'bind_addr' => '[::]',
      'retry_join'                 => sort($nodes),
      'tls'                        => {
        'defaults'    => {
          'verify_outgoing' => true,
          'verify_incoming' => true,
          'ca_file'         => '/etc/consul.d/ca.pem',
          'cert_file'       => "/etc/consul.d/${trusted['certname']}_cert.pem",
          'key_file'        => "/etc/consul.d/${trusted['certname']}_key.pem",
        },
      },
      'server_name'                => $trusted['certname'],
      'node_name'                  => $trusted['certname'],
      'disable_update_check'       => true,
      'enable_local_script_checks' => true,
      'bootstrap_expect'           => 3,
      'ui_config'                  => { 'enabled' => true, },
    },
  }
  systemd::dropin_file { 'foo.conf':
    unit           => 'consul.service',
    content        => "[Unit]\nConditionFileNotEmpty=\nConditionFileNotEmpty=/etc/consul.d/config.json",
    notify_service => true,
  }
  $cert = "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem"
  file { "/etc/consul.d/${trusted['certname']}_key.pem":
    ensure  => 'file',
    owner   => 'consul',
    group   => 'consul',
    mode    => '0400',
    source  => $cert,
    require => Package['consul'],
    notify  => Service['consul'],
  }
  file { "/etc/consul.d/${trusted['certname']}_cert.pem":
    ensure  => 'file',
    owner   => 'consul',
    group   => 'consul',
    mode    => '0400',
    source  => "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",
    require => Package['consul'],
    notify  => Service['consul'],
  }
  file { '/etc/consul.d/ca.pem':
    ensure  => 'file',
    owner   => 'consul',
    group   => 'consul',
    mode    => '0400',
    source  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    require => Package['consul'],
    notify  => Service['consul'],
  }
}
