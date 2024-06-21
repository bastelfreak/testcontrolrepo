package { 'openssh':
  require => Package['htop'],
}
package { 'htop':
  require => Package['openssh'],
}
