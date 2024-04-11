plan testmodule::test {
  $nodes = puppetdb_query('resources[certname] { type = "Class" and title in [ "Puppet_enterprise::Profile::Master", "Puppet_enterprise::Profile::Puppetdb"] group by certname }').map |$fqdn| {$fqdn['certname']}
  out::message($nodes)
}
