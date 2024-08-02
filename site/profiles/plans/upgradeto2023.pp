#
# @summary calls peadm::upgrade + sanity checks. supposed to be executed via systemd unit
#
# @param primary_host the FQDN/common name of the primary, passed to peadm::convert
# @param version always points to the latest LTS
# @param pe_installer_source optional URL to the PE builds, can point to a webdir or absolute URL
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan profiles::upgradeto2023 (
  Peadm::SingleTargetSpec $primary_host,
  Peadm::Pe_version $version = '2023.7.0',
  Optional[Stdlib::HTTPSUrl] $pe_installer_source = undef,
) {
  run_plan('profiles::convert', { 'primary_host' => $primary_host, 'version' => $version, 'pe_installer_source' => $pe_installer_source }.delete_undef_values )
}
