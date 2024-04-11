plan testmodule::test {
  $primary = puppetdb_query('resources[certname] { type = "Class" and title in [ "Puppet_enterprise::Profile::Certificate_authority", "Puppet_enterprise::Profile::Database"] group by certname }').map |$fqdn| {$fqdn['certname']}
  $legacy_primary = puppetdb_query('resources[certname] { type = "Class" and title = "Puppet_enterprise::Profile::Certificate_authority" group by certname }').map |$fqdn| {$fqdn['certname']} - $primary
  $replica = puppetdb_query('resources[certname] { type = "Class" and title = "Puppet_enterprise::Profile::Primary_master_replica" group by certname }').map |$fqdn| {$fqdn['certname']}
  $compiler = puppetdb_query('resources[certname] { type = "Class" and title in [ "Puppet_enterprise::Profile::Master", "Puppet_enterprise::Profile::Puppetdb"] group by certname }').map |$fqdn| {$fqdn['certname']} - $primary
  $legacy_compiler = puppetdb_query('resources[certname] { type = "Class" and title = "Puppet_enterprise::Profile::Master" group by certname }').map |$fqdn| {$fqdn['certname']} - $compiler - $primary
  $postgres = puppetdb_query('resources[certname] { type = "Class" and title = "Puppet_enterprise::Profile::Database" group by certname }').map |$fqdn| {$fqdn['certname']} - $primary

  $data = {
    'primary'         => $primary,
    'legacy_primary'  => $legacy_primary,
    'replica'         => $replica,
    'compiler'        => $compiler,
    'legacy_compiler' => $legacy_compiler,
    'postgres'        => $postgres,
  }
  return $data
}
