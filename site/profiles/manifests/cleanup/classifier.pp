#
# @summary ensures that the classifier data backend is available
#
# @api private
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::cleanup::classifier {
  # when the option isn't set, the classifier won't work as a Hiera backend
  # the backend is required for PEADM
  # the Hiera backend classifier_data, usually defined in `/etc/puppetlabs/puppet/hiera.yaml`,
  # hardcodes `puppet_enterprise_classifier_data_backend_present` to true
  $classifier = lookup('puppet_enterprise_classifier_data_backend_present', Boolean, 'first', false)
  unless $classifier {
    fail('puppet_enterprise_classifier_data_backend_present needs to be set to `true` in Hiera!')
  }
}
