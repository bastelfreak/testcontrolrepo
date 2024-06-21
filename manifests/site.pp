stage { 'pre': }
stage { 'post': }
stage { 'postpost': }

Stage['pre'] -> Stage['main'] -> Stage['post'] -> Stage['postpost']

class foo {
  file { '/tmp/numbers':
    ensure => 'file',
  }
}
class { 'foo':
  stage => 'pre',
}

class htop {
  package { 'htop':
    ensure => 'installed',
  }
}
class { 'htop':
  stage  => 'pre',
}

class openssh {
  package { 'openssh':
    ensure => 'installed',
  }
}
class { 'openssh':
  stage  => 'main',
}

class rangee {
  $fpath = '/tmp/numbers'
  range(0, 7000).each |$element| {
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
}

class { 'rangee':
  stage => 'post',
}

class bash {
  package { 'bash':
    ensure => 'installed',
  }
}
class { 'bash':
  stage  => 'postpost',
}
