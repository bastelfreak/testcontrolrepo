#
# @summary installs bolt via yumrepo or release package
#
# @param version
# @param base_url
# @param gpgkey
# @param use_release_package
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class bolt (
  String[1] $version = '3.29.0',
  Stdlib::HTTPSUrl $base_url = 'https://yum.puppet.com/',
  String[1] $release_package = "puppet-tools-release-el-${facts['os']['release']['major']}.noarch.rpm",
  String[1] $gpgkey = 'RPM-GPG-KEY-puppet-20250406',
  Boolean $use_release_package = true,
) {
  unless $facts['os']['family'] == 'RedHat' {
    fail('class bolt only works on RedHat OS family')
  }

  if $use_release_package {
    package { 'puppet-tools-release':
      ensure => present,
      source => "${base_url}${release_package}",
      before => Package['puppet-bolt'],
    }
  } else {
    yumrepo { 'puppet-tools':
      ensure   => 'present',
      baseurl  => "${base_url}puppet-tools/el/${facts['os']['release']['major']}/\$basearch",
      descr    => "Puppet Tools Repository el ${facts['os']['release']['major']} - \$basearch",
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => "${base_url}${gpgkey}",
      before   => Package['puppet-bolt'],
    }
  }

  package { 'puppet-bolt':
    ensure  => $version,
  }
}
