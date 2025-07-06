#mod 'WhatsARanjit/node_manager', '0.8.0'
mod 'puppetlabs/node_manager', '1.1.0' # to cleanup existing node groups, was migrated to Perforce but not released yet

mod 'ipcrm/echo', '0.1.8' # for debug output during testing

mod 'puppetlabs/pe_status_check', '4.6.0' # implements prechecks

mod 'puppetlabs/stdlib', '9.7.0' # various datatypes used in the other modules

#mod 'puppetlabs-peadm', '3.21.0' # provides the peadm::convert and peadm::upgrade plans
mod 'puppetlabs-peadm',
  git: 'https://github.com/bastelfreak/puppetlabs-peadm',
  branch: 'issue-469'

mod 'puppetlabs-apply_helpers', '0.3.0'     # peadm dependency
mod 'puppet-format', '1.1.1'                # peadm dependency
mod 'puppetlabs-service', '3.1.0'           # peadm dependency
mod 'puppetlabs-package', '3.1.0'           # peadm dependency
mod 'puppetlabs-inifile', '6.2.0'           # peadm dependency
mod 'puppetlabs-ruby_task_helper', '1.0.0'  # peadm dependency

mod 'puppetlabs-puppet_agent', '4.22.0' # configures puppet agent
mod 'puppetlabs-facts', '1.7.0'         # puppet_agent dependency
mod 'puppetlabs/puppet_conf', '2.1.0'   # retrieves/updates the environment option in puppet.conf
mod 'puppet/extlib', '7.5.1'            # retrieves/updates the environment option in puppet.conf

mod 'puppet/bolt', '1.8.0'    # installs bolt
mod 'puppet/systemd', '8.1.0' # required to write the bolt unit
mod 'saz-sudo', '9.0.1'       # required because we call peadm::* as normal user

mod 'puppetlabs-facter_task', '2.1.0' # for debugging
mod 'puppetlabs-exec', '3.1.0'        # for debugging

# consul
mod 'puppet/consul',
  git: 'https://github.com/bastelfreak/puppet-consul',
  branch: 'archive'
mod 'puppet/hashi_stack',
  git: 'https://github.com/voxpupuli/puppet-hashi_stack',
  branch: 'master'
