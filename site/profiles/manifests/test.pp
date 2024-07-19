#
# @summary demo profile to configure bolt for peadm convert
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::test (
  Peadm::Pe_version $version = '2021.7.8',
) {
  # create a new bolt project
  bolt::project { 'peadmmig': }

  -> file { '/opt/peadmmig/profiles::convert.json':
    owner   => 'peadmmig',
    group   => 'peadmmig',
    content => { 'primary_host' => $facts['networking']['fqdn'] }.stdlib::to_json_pretty,
  }
  -> file { '/opt/peadmmig/profiles::upgrade.json':
    owner   => 'peadmmig',
    group   => 'peadmmig',
    content => { 'primary_host' => $facts['networking']['fqdn'], 'version' => $version }.stdlib::to_json_pretty,
  }
  -> file { '/opt/peadmmig/profiles::upgradeto2021.json':
    owner   => 'peadmmig',
    group   => 'peadmmig',
    content => { 'primary_host' => $facts['networking']['fqdn'], 'version' => '2021' }.stdlib::to_json_pretty,
  }
  -> file { '/opt/peadmmig/profiles::upgradeto2023.json':
    owner   => 'peadmmig',
    group   => 'peadmmig',
    content => { 'primary_host' => $facts['networking']['fqdn'], 'version' => '2023' }.stdlib::to_json_pretty,
  }
}
