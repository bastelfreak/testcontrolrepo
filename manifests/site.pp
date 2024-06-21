stage { 'pre': }
stage { 'post': }
stage { 'postpost': }

Stage['pre'] -> Stage['main'] -> Stage['post'] -> Stage['postpost']

$fpath = '/tmp/numbers'

class foo {
  file { $fpath:
    ensure => 'file',
  }
}
class { 'foo':
  stage => 'pre',
}
package { 'htop':
  ensure => 'installed',
  stage  => 'pre',
}
package { 'openssh':
  ensure => 'installed',
  stage  => 'main',
}
range(0, 8000).each |$element| {
  $require = if ($element % 2) == 0 {
    [File[$fpath],Package['openssh']]
  } else {
    [File[$fpath],Package['htop']]
  }
  file_line { "${element}-${fpath}":
    path    => $fpath,
    line    => "${element}\n",
    require => $require,
    stage   => 'post',
  }
}

package { 'pe-r10k':
  ensure => 'installed',
  stage  => 'postpost',
}
