#
# @summary removess bad data from pe.conf and ensures that the environment is correct
#
# @param validated_env hash with the correct environment
# @param show_diff hide the file diff
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::cleanup::pe_conf (
  Hash $validated_env,
  Boolean $show_diff = false,
){
  $pepath = '/etc/puppetlabs/enterprise/conf.d/pe.conf'
  $pe = profiles::readhocon($pepath)

  $pe_wo_remote = if $pe['puppet_enterprise::profile::master::r10k_remote'] {
    echo { 'pe.conf contains puppet_enterprise::profile::master::r10k_remote, removing it':
      withpath => false,
    }
    $pe - 'puppet_enterprise::profile::master::r10k_remote'
  } else {
    $pe
  }

  # ensure we set the correct environment in pe.conf
  # https://www.puppet.com/docs/pe/latest/upgrade_pe#update_environment
  $pe_final = if $validated_env['correct_env'] == 'production' {
    $pe_wo_remote
  } else {
    $env_data = {
      'pe_install::install::classification::pe_node_group_environment'   => $validated_env['correct_env'],
      'puppet_enterprise::master::recover_configuration::pe_environment' => $validated_env['correct_env'],
    }
    $pe_wo_remote + $env_data
  }
  if $pe_final != $pe_wo_remote {
    echo { "pe.conf does not set the correct environment for PE infra, setting it to ${validated_env['correct_env']}":
      withpath => false,
    }
  }

  # when the initial and final config differ we know we modified it and need to write it
  # we're doing this hula hoop jumping because the original file contains comments, but readhocon() strips those
  # So writing the original config back to the file would drop the comments => trigger a corrective change on each run
  if $pe != $pe_final {
    file { $pepath:
      ensure    => 'file',
      content   => stdlib::to_json_pretty($pe_final),
      show_diff => $show_diff,
    }
  }
}
