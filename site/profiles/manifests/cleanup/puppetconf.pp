#
# @api private
#
# @param env the desired environment setting for the agent section
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::cleanup::puppetconf (
  String[1] $env,
) {
  echo { "puppet.conf doesn't contain correct env, adding '${env}' to agent section":
    withpath => false,
  }
  # it is save to assume that the environment element isn't managed already, or it's managed wrong
  ini_setting { 'puppet.conf environment':
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
    setting => 'environment',
    value   => $env,
  }
}
