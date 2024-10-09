node default {
  if $facts['pe_status_check_role'] == 'primary' {
    include profiles::boltprojects
  }
}
