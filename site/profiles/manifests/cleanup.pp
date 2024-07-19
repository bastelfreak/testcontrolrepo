#
# @summary removes r10k_remote from the master node group
#
class profiles::cleanup {
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

  # cleanup the node classifier data only when the hiera settings are already written
  # this ensures that we don't brick our deployment (assume the initial run removes the data from the node classifier and wants to update code-manager config via hiera but that fails.
  unless $facts['codemanager_config'] {
    fail('codemanager_config fact is missing')
  }
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
      } else {
        $new_classes = $classes
      }
    } else {
      $new_classes = undef
      # only for debugging, remove later
      echo { "no classes hash in node group ${group}":
        withpath => false,
      }
    }
    if $data {
      if dig($data, 'puppet_enterprise::profile::master') {
        echo { "puppet_enterprise::profile::master set in node group ${group} in data section. Please move it to Hiera: ${data['puppet_enterprise::profile::master']}":
          withpath => false,
        }
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
          $new_data = if $master_data['puppet_enterprise::profile::master'].empty {
            $data_without_master
          } else {
            $data_without_master + $master_data
          }
        }
      } else {
        $new_data = $data
      }
    } else {
      $new_data = undef
      # only for debugging, remove later
      echo { "no data hash in node group ${group}":
        withpath => false,
      }
    }
    node_group { $group:
      data           => $new_data,
      classes        => $new_classes,
      purge_behavior => 'all',
      # purge read only attributes + data
      *              => $node_group - ['environment_trumps', 'last_edited', 'serial_number', 'config_data', 'id', 'classes'],
    }
  } else {
    echo { '\'puppet_enterprise::master::code_manager::sources\' in hiera but not yet written to the config. Not updating PE classifier node groups':
      withpath => false,
    }
    $new_data = undef
  }
}
