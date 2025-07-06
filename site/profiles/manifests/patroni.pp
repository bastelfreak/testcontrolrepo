class profiles::patroni {
  require profiles::consul
  $nodes = [
    'server1.tim.betadots.training',
    'server2.tim.betadots.training',
    'server3.tim.betadots.training',
  ]

  class { 'patroni':
    install_method          => 'package',
    manage_postgresql_repo  => false,
    manage_postgresql       => true,
    config_path             => '/etc/patroni/patroni.yml',
    scope                   => 'cluster',
    use_consul              => true,
    consul_host             => $facts['networking']['fqdn'],
    consul_cacert           => '/etc/patroni/ca.pem',
    consul_cert             => "/etc/patroni/${trusted['certname']}_cert.pem",
    consul_key              => "/etc/patroni/${trusted['certname']}_key.pem",
    pgsql_connect_address   => "${facts['networking']['fqdn']}:5432",
    restapi_connect_address => "${facts['networking']['fqdn']}:8008",
    pgsql_parameters        => {
      'max_connections' => 500,
    },
    bootstrap_pg_hba        => [
      'local all postgres ident',
      'host all all 0.0.0.0/0 scram-sha-256',
      'host replication repl 0.0.0.0/0 scram-sha-256',
    ],
    pgsql_pg_hba            => [
      'local all postgres ident',
      'host all all 0.0.0.0/0 scram-sha-256',
      'host replication repl 0.0.0.0/0 scram-sha-256',
    ],
    superuser_username      => 'postgres',
    superuser_password      => 'postgrespassword',
    replication_username    => 'repl',
    replication_password    => 'replpassword',
  }
  file { "/etc/patroni/${trusted['certname']}_key.pem":
    ensure  => 'file',
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0400',
    source  => "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
    require => Package['patroni'],
    notify  => Service['patroni'],
  }
  file { "/etc/patroni/${trusted['certname']}_cert.pem":
    ensure  => 'file',
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0400',
    source  => "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",
    require => Package['patroni'],
    notify  => Service['patroni'],
  }
  file { '/etc/patroni/ca.pem':
    ensure  => 'file',
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0400',
    source  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    require => Package['patroni'],
    notify  => Service['patroni'],
  }
}
