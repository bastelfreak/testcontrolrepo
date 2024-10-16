#
# @summary demo profile to configure bolt for peadm convert
#
# @param version our default version to upgrade to
# @param version_2021 latest PE 2021 version
# @param version_2023 latest PE 2023 version
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::boltprojects (
  Peadm::Pe_version $version = '2021.7.8',
  Peadm::Pe_version $version_2021 = $version,
  Peadm::Pe_version $version_2023 = '2023.7.0',
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
    content => { 'primary_host' => $facts['networking']['fqdn'], 'version' => $version_2021 }.stdlib::to_json_pretty,
  }
  -> file { '/opt/peadmmig/profiles::upgradeto2023.json':
    owner   => 'peadmmig',
    group   => 'peadmmig',
    content => { 'primary_host' => $facts['networking']['fqdn'], 'version' => $version_2023 }.stdlib::to_json_pretty,
  }
}
