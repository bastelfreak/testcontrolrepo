$fpath = '/tmp/numbers'
file { $fpath:
  ensure => 'file',
}
range(0, 10000).each |$element| {
  file_line { "${element}-${fpath}":
    path => $fpath,
    line => "${element}\n",
  }
}
