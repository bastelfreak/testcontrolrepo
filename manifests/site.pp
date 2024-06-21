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
  file_line { "${element}-${fpath}":
    path    => $fpath,
    line    => "${element}\n",
  }
}
