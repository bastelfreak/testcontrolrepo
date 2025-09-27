node default {
  if $facts['pe_status_check_role'] == 'primary' {
    include profiles::boltprojects
  }
  echo { 'r10k':
    message => "${profiles::r10k_deploy()}",
  }
}
