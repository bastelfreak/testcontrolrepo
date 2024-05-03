#
# @summary demo profile to configure bolt for peadm convert
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::test {
  # create a new bolt project
  bolt::project { 'peadmmig': }

  -> file { '/opt/peadmmig/test::convert.json':
    owner   => 'peadmmig',
    group   => 'peadmmig',
    content => { 'primary_host' => $facts['networking']['fqdn'] }.stdlib::to_json_pretty,
  }
}
