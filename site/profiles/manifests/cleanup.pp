#
# @summary prepares a PE environment for a peadm::convert && peadm::upgrade
#
# @param show_diff shows the diff for file resources. Set to true for debugging
# @param repo url to the control repository
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::cleanup (
  Boolean $show_diff = false,
  String[1] $repo = 'https://github.com/voxpupuli/controlrepo',
) {

  # ensure the control repos are configured correctly in Hiera
  profiles::validate_control_repo_sources_in_hiera($repo)

  # the fact needs to be present. if it's missing something is wrong
  unless $facts['codemanager_config'] {
    fail('codemanager_config fact is missing')
  }

  $validated_env = profiles::validate_env_puppet()

  unless $validated_env['config_is_correct'] {
    class { 'profiles::cleanup::puppetconf':
      env => $validated_env['correct_env'],
    }
  }

  # cleanup the node classifier data only when the hiera settings are already written
  # this ensures that we don't brick our deployment (assume the initial run removes the data from the node classifier and wants to update code-manager config via hiera but that fails.
  if fact('codemanager_config.sources') {

    # check if the data in the code manager config is correct
    profiles::validate_code_manager_sources($repo, $facts['codemanager_config']['sources'])

    # check if user_data.conf contains bad data and clean it up
    class { 'profiles::cleanup::user_data':
      show_diff => $show_diff,
    }
    contain profiles::cleanup::user_data

    # check if pe.conf contains bad/missing data and clean it up
    class { 'profiles::cleanup::pe_conf':
      validated_env => $validated_env,
      show_diff     => $show_diff,
    }
    contain profiles::cleanup::pe_conf

    # check if the PE Master node group has data that needs to be removed
    contain profiles::cleanup::node_group
  } else {
    echo { '\'puppet_enterprise::master::code_manager::sources\' in hiera but not yet written to the config. Not updating PE classifier node groups':
      withpath => false,
    }
  }

  # validate hiera data for puppet agents
  contain profiles::cleanup::agent
}
