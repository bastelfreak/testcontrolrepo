mod 'WhatsARanjit/node_manager', '0.8.0' # to cleanup existing node groups, was migrated to Perforce but not released yet

mod 'ipcrm/echo', '0.1.8' # for debug output during testing

mod 'puppetlabs/pe_status_check', # check if infra is healthy, https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/226
  git: 'https://github.com/bastelfreak/puppetlabs-pe_status_check',
  branch: 'plans'

mod 'puppetlabs/stdlib', '9.6.0' # various datatypes used in the other modules

mod 'puppetlabs-peadm', # provides the peadm::convert and peadm::upgrade plans
  git: 'https://github.com/bastelfreak/puppetlabs-peadm',
  branch: 'foo'

mod 'puppetlabs-apply_helpers', '0.3.0'     # peadm dependency
mod 'puppet-format', '1.1.1'                # peadm dependency
mod 'puppetlabs-service', '3.0.0'           # peadm dependency
mod 'puppetlabs-package', '3.0.1'           # peadm dependency
mod 'puppetlabs-inifile', '6.1.1'           # peadm dependency
mod 'puppetlabs-ruby_task_helper', '0.6.1'  # peadm dependency

mod 'puppetlabs-puppet_agent', '4.19.0' # configures puppet agent
mod 'puppetlabs-facts', '1.4.0'         # puppet_agent dependency

mod 'puppet/systemd', '7.0.0' # required to write the bolt unit
