package { 'openssh':
  ensure => 'installed',
}
package { 'htop':
  ensure => 'installed',
}

file { '/tmp/numbers':
  ensure => 'file',
}

$fpath = '/tmp/numbers'
range(0, 4000).each |$element| {
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
