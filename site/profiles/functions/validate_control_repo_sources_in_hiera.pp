#
# @summary ensures that we've the correct hiera data of control-repositories
#
# @param repo the control-repository with all bolt plans
#
# @author Tim Meusel <tim@bastelfreak.de>
#
function profiles::validate_control_repo_sources_in_hiera (String[1] $repo) {
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
    unless $repo in $with_prefix.map |$key, $value| { $value['remote'] } {
      fail("Remote '${repo}' isn't configured as puppet_enterprise::master::code_manager::sources in hiera")
    }
  }
}
