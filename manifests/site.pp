$path = '/tmp/numbers'
file { $path:
  ensure => 'file',
}
range(0, 10000).each |$element| {
  file_line { $element:
    path => $path,
    line => "${element}\n",
  }
}
