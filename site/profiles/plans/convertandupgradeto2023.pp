#
# @summary calls peadm::convert & peadm::upgrade + sanity checks. supposed to be executed via systemd unit
#
# @param primary_host the FQDN/common name of the primary, passed to peadm::convert
# @param version always points to the latest LTS
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::convertandupgradeto2023 (
  Peadm::SingleTargetSpec $primary_host,
  Peadm::Pe_version $version = '2023.8.0',
) {
  run_plan('profiles::convert', { 'primary_host' => $primary_host,})
  $data = {
    'primary_host' => $primary_host,
    'version' => $version,
  }
  run_plan('profiles::upgradeto2023', $data )
}
