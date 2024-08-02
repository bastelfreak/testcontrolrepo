#
# @summary removes bad data from user_data.conf
#
# @param show_diff shows the diff of the user_data.conf file
#
# @api private
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::cleanup::user_data (
  Boolean $show_diff = false,
) {
  # also cleanup the pe.conf
  $userdatapath = '/etc/puppetlabs/enterprise/conf.d/user_data.conf'
  $userdata = profiles::readhocon($userdatapath)
  if $userdata['puppet_enterprise::profile::master::r10k_remote'] {
    echo { 'user_data.conf contains puppet_enterprise::profile::master::r10k_remote, removing it':
      withpath => false,
    }
    file { $userdatapath:
      ensure    => 'file',
      content   => stdlib::to_json_pretty($userdata.sort - 'puppet_enterprise::profile::master::r10k_remote'),
      show_diff => $show_diff,
    }
  }
}
