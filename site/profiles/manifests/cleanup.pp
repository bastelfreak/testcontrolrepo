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
        node_group { $group:
          classes        => $new_classes,
          purge_behavior => 'classes',
          # purge read only attributes + classes
          *              => $node_group - ['environment_trumps', 'last_edited', 'serial_number', 'config_data', 'id','classes',],
        }
      }
    } else {
      echo { "no classes hash in node group ${group}":
        withpath => false,
      }
    }
    if dig($data, 'puppet_enterprise::profile::master') {
      echo { "puppet_enterprise::profile::master set in node group ${group} in data section. Please move it to Hiera: ${data['puppet_enterprise::profile::master']}":
        withpath => false,
      }
      if dig($data, 'puppet_enterprise::profile::master', 'r10k_remote') {
        echo { "r10k_remote set in node group ${group} in data section, removing it":
          withpath => false,
        }
        # keep every parameter except r10k_remote
        $master = { 'puppet_enterprise::profile::master' => $data['puppet_enterprise::profile::master'] - 'r10k_remote' }
        $new_data = $data + $master
        node_group { $group:
          data           => $new_data,
          purge_behavior => 'data',
          # purge read only attributes + data
          *              => $node_group - ['environment_trumps', 'last_edited', 'serial_number', 'config_data', 'id', 'classes'],
        }
      }
    }
  } else {
    echo { '\'puppet_enterprise::master::code_manager::sources\' in hiera but not yet written to the config. Not updating PE classifier node groups':
      withpath => false,
    }
  }
}
