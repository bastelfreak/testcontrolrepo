#
# @summary removes r10k_remote from the master node group
#
class profiles::cleanup {
  $sources = lookup('puppet_enterprise::master::code_manager::sources', Hash[String[1],Hash[String[1],Variant[String[1],Boolean]]], 'deep', {})
  if $sources.empty {
    fail('puppet_enterprise::master::code_manager::sources needs to be set in Hiera')
  }
  $group = 'PE Master'
  $data = dig(node_groups($group))[$group]
  $classes = dig($data, 'classes')
  if $classes {
    if dig($classes, 'puppet_enterprise::profile::master', 'r10k_remote') {
      echo { "r10k_remote not set in node group ${group}":
        withpath => false,
      }
      $master = { 'puppet_enterprise::profile::master' => $classes['puppet_enterprise::profile::master'] - 'r10k_remote' }
      $new_classes = $classes + $master
      node_group { $group:
        classes        => $new_classes,
        purge_behavior => 'classes',
        # purge read only attributes + classes
        *              => $data - ['environment_trumps', 'last_edited', 'serial_number', 'config_data', 'id','classes',],
      }
    }
  } else {
    echo { "no classes hash in node group ${group}":
      withpath => false,
    }
  }
}
