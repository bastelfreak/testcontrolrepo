#
# @summary removes r10k_remote from the master node group
#
# @param show_diff shows the diff for file resources. Set to true for debugging
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::cleanup (
  Boolean $show_diff = false,
) {
  $sources = lookup('puppet_enterprise::master::code_manager::sources', Hash[String[1],Hash[String[1],Variant[String[1],Boolean]]], 'deep', {})
  if $sources.empty {
    fail('\'puppet_enterprise::master::code_manager::sources\' needs to be set in Hiera')
  } else {
    # do some further validation. There should be one main repo with prefix=false and N repos with prefix=true
    if $sources.length < 2 {
      fail('\'puppet_enterprise::master::code_manager::sources\' needs at least two repos')
    }
    $with_prefix = $sources.filter |String[1] $name, Hash[String[1],Variant[String[1],Boolean]] $data| {
      $data['prefix'] == true
    }
    if $with_prefix.length == 0 {
      fail('\'puppet_enterprise::master::code_manager::sources\' needs 1 or more repos with prefix=>true')
    }
    if ($sources.length - $with_prefix.length) != 1 {
      fail("'puppet_enterprise::master::code_manager::sources' can only have one repo with prefix=>false. But it's set to ${sources}")
    }
  }

  # the fact needs to be present. if it's missing something is wrong
  unless $facts['codemanager_config'] {
    fail('codemanager_config fact is missing')
  }

  # cleanup the node classifier data only when the hiera settings are already written
  # this ensures that we don't brick our deployment (assume the initial run removes the data from the node classifier and wants to update code-manager config via hiera but that fails.
  if fact('codemanager_config.sources') {
    $group = 'PE Master'
    $node_group = dig(node_groups($group))[$group]
    $classes = dig($node_group, 'classes')
    $data = dig($node_group, 'config_data')
    if $classes {
      if dig($classes, 'puppet_enterprise::profile::master', 'r10k_remote') {
        echo { "r10k_remote set in node group ${group} in classes section, removing it":
          withpath => false,
        }
        $master = { 'puppet_enterprise::profile::master' => $classes['puppet_enterprise::profile::master'] - 'r10k_remote' }
        $new_classes = $classes + $master
        # flag that we use later to determine if we want to update the node_group
        $flag_classes = true
      } else {
        $new_classes = $classes
        $flag_classes = false
      }
    } else {
      $new_classes = undef
      $flag_classes = false
      # only for debugging, remove later
      echo { "no classes hash in node group ${group}":
        withpath => false,
      }
    }
    if $data {
      if dig($data, 'puppet_enterprise::profile::master', 'r10k_remote') or dig($data, 'puppet_enterprise::profile::master', 'code_manager_auto_configure') {
        echo { "r10k_remote and/or code_manager_auto_configure set in node group ${group} in data section, removing it":
          withpath => false,
        }
        # keep every parameter except r10k_remote and code_manager_auto_configure
        # r10k_remote isn't needed anymore. code_manager_auto_configure should be set on the classes hash (default) or Hiera
        # We need to purge it here because the PE upgrade will add it to the class if it's missing there.
        # And when data is in config_data and classes it conflicts and the upgrade aborts
        $data_without_master = $data - 'puppet_enterprise::profile::master'
        $master_data = { 'puppet_enterprise::profile::master' => $data['puppet_enterprise::profile::master'] - ['r10k_remote', 'code_manager_auto_configure'] }
        # if $master['puppet_enterprise::profile::master'] is am empty hash because it only contained r10k_remote and/or code_manager_auto_configure,
        # we will remove it completely
        # Otherwise we will add the reduced hash $master to $data_without_master
        if $master_data['puppet_enterprise::profile::master'].empty {
          $new_data = $data_without_master
        } else {
          echo { "puppet_enterprise::profile::master set in node group ${group} in data section. Please move it to Hiera: ${master_data}":
            withpath => false,
          }
          $new_data = $data_without_master + $master_data
        }
        # flag that we use later to determine if we want to update the node_group
        $flag_data = true
      } else {
        $new_data = $data
        $flag_data = false
      }
    } else {
      $new_data = undef
      $flag_data = false
      # only for debugging, remove later
      echo { "no data hash in node group ${group}":
        withpath => false,
      }
    }
    # we use a condition here because we don't want to hammer the classifier API when we don't expect changes
    # This is a safeguard to ensure that we don't modify the node group by accident. Out input comes in part from node_group(),
    # which has a bit of a different output compared to the input of the node_group resource
    # https://github.com/puppetlabs/puppetlabs-node_manager/issues/92
    # Also the node_group isn't idempotent. It tries to set the parent group always to the UID of the group, but resource prefetching provides us the name...
    if $flag_classes or $flag_data {
      node_group { $group:
        data           => $new_data,
        classes        => $new_classes,
        purge_behavior => 'all',
        # purge read only attributes + data
        *              => $node_group - ['environment_trumps', 'last_edited', 'serial_number', 'config_data', 'id', 'classes', 'deleted'],
      }
    }

    # also cleanup the pe.conf
    $pepath = '/etc/puppetlabs/enterprise/conf.d/pe.conf'
    $pe = profiles::readhocon($pepath)

    # { 'config_is_correct' => true, 'correct_env' => true, }
    $validated_env = profiles::environment($primary_host)
    if $validated_env['config_is_correct'] == false or $pe['puppet_enterprise::profile::master::r10k_remote'] {
      $pe_wo_remote = if $pe['puppet_enterprise::profile::master::r10k_remote'] {
        echo {'pe.conf contains puppet_enterprise::profile::master::r10k_remote, removing it':
          withpath => false,
        }
        $pe - 'puppet_enterprise::profile::master::r10k_remote'
      } else{
        $pe
      }
      # ensure we set the correct environment in pe.conf
      # https://www.puppet.com/docs/pe/latest/upgrade_pe#update_environment
      $pe_final = if $validated_env['config_is_correct'] {
        $pe_wo_remote
      } else {
        echo {"pe.conf does not set the non-standard env '${$validated_env['correct_env']}', adding it":
          withpath => false,
        }
        $data = {
          'pe_install::install::classification::pe_node_group_environment'   => $validated_env['correct_env'],
          'puppet_enterprise::master::recover_configuration::pe_environment' => $validated_env['correct_env'],
        }
        $pe_wo_remote + $data
      }
      file { $pepath:
        ensure    => 'file',
        content   => stdlib::to_json_pretty($pe_final),
        show_diff => $show_diff,
      }
    }

    # also cleanup the pe.conf
    $userdatapath = '/etc/puppetlabs/enterprise/conf.d/user_data.conf'
    $userdata = profiles::readhocon($userdatapath)
    if $userdata['puppet_enterprise::profile::master::r10k_remote'] {
      echo {'user_data.conf contains puppet_enterprise::profile::master::r10k_remote, removing it':
        withpath => false,
      }
      file { $userdatapath:
        ensure    => 'file',
        content   => stdlib::to_json_pretty($userdata - 'puppet_enterprise::profile::master::r10k_remote'),
        show_diff => $show_diff,
      }
    }
  } else {
    echo { '\'puppet_enterprise::master::code_manager::sources\' in hiera but not yet written to the config. Not updating PE classifier node groups':
      withpath => false,
    }
  }
}
