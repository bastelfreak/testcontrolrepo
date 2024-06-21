$fpath = '/tmp/numbers'
file { $fpath:
  ensure => 'file',
}
package { 'htop':
  ensure => 'installed',
}
package { 'openssh':
  ensure => 'installed',
}
range(0, 40000).each |$element| {
  $require = if ($element % 2) == 0 {
    [File[$fpath],Package['openssh']]
  } else {
    [File[$fpath],Package['htop']]
  }
  file_line { "${element}-${fpath}":
    path    => $fpath,
    line    => "${element}\n",
    require => $require,
  }
}
