#
# @summary ensures that the classifier data backend is available
#
# @api private
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class profiles::cleanup::classifier {
  # ensure agents are configured to update themself
  # when the option isn't set, the classifier won't work as a Hiera backend
  # the backend is required for PEADM
  $classifier = lookup('puppet_enterprise_classifier_data_backend_present', Boolean, 'first', 'false')
  unless $classifier {
    fail('puppet_enterprise_classifier_data_backend_present needs to be set to `true` in Hiera!')
  }
}
