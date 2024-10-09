#mod 'WhatsARanjit/node_manager', '0.8.0'
mod 'puppetlabs/node_manager', '1.0.1' # to cleanup existing node groups, was migrated to Perforce but not released yet

mod 'ipcrm/echo', '0.1.8' # for debug output during testing

mod 'puppetlabs/pe_status_check', # check if infra is healthy, https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/226
  git: 'https://github.com/bastelfreak/puppetlabs-pe_status_check',
  branch: 'plans'

mod 'puppetlabs/stdlib', '9.6.0' # various datatypes used in the other modules

mod 'puppetlabs-peadm', '3.21.0' # provides the peadm::convert and peadm::upgrade plans
#mod 'puppetlabs-peadm',
#  git: 'https://github.com/bastelfreak/puppetlabs-peadm',
#  branch: 'url'

mod 'puppetlabs-apply_helpers', '0.3.0'     # peadm dependency
mod 'puppet-format', '1.1.1'                # peadm dependency
mod 'puppetlabs-service', '3.0.0'           # peadm dependency
mod 'puppetlabs-package', '3.0.1'           # peadm dependency
mod 'puppetlabs-inifile', '6.1.1'           # peadm dependency
mod 'puppetlabs-ruby_task_helper', '0.6.1'  # peadm dependency

mod 'puppetlabs-puppet_agent', '4.20.1' # configures puppet agent
mod 'puppetlabs-facts', '1.4.0'         # puppet_agent dependency
mod 'puppetlabs/puppet_conf', '2.0.0'   # retrieves/updates the environment option in puppet.conf
mod 'puppet/extlib', '7.2.0'            # retrieves/updates the environment option in puppet.conf

mod 'puppet/bolt', '1.1.1'    # installs bolt
mod 'puppet/systemd', '7.1.0' # required to write the bolt unit
mod 'saz-sudo', '8.0.0'       # required because we call peadm::* as normal user

mod 'puppetlabs-facter_task', '2.0.1' # for debugging
mod 'puppetlabs-exec', '3.0.0'        # for debugging
