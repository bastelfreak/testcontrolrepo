#
# @summary ensures that the puppet agents have the correct config to update themself
#
# @api private
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::cleanup::agent {
  # ensure agents are configured to update themself
  $version = lookup('puppet_agent::version', String[1], 'first', 'notauto')
  unless $version == 'auto' {
    fail('puppet_agent::version needs to be set to `auto` in Hiera!')
  }
}
