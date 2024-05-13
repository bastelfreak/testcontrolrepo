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
    $with_prefix = $sources.map |String[1] $name, Hash[String[1],Variant[String[1],Boolean]] $data| {
      $data['prefix'] == true
    }
    if $with_prefix.length == 0 {
      fail('\'puppet_enterprise::master::code_manager::sources\' needs 1 or more repos with prefix=>true')
    }
    if ($sources.length - $with_prefix.length) != 1 {
      fail('\'puppet_enterprise::master::code_manager::sources\' can only have one repo with prefix=>false')
    }
  }
  $group = 'PE Master'
  $data = dig(node_groups($group))[$group]
  $classes = dig($data, 'classes')
  if $classes {
    if dig($classes, 'puppet_enterprise::profile::master', 'r10k_remote') {
      $master = { 'puppet_enterprise::profile::master' => $classes['puppet_enterprise::profile::master'] - 'r10k_remote' }
      $new_classes = $classes + $master
      node_group { $group:
        classes        => $new_classes,
        purge_behavior => 'classes',
        # purge read only attributes + classes
        *              => $data - ['environment_trumps', 'last_edited', 'serial_number', 'config_data', 'id','classes',],
      }
    } else {
      echo { "r10k_remote not set in node group ${group}":
        withpath => false,
      }
    }
  } else {
    echo { "no classes hash in node group ${group}":
      withpath => false,
    }
  }
}
