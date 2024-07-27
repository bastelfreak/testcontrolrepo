# @summary return Hocon data
Puppet::Functions.create_function(:'profiles::readhocon') do
  # @example Calling the function
  #   boltdir()
  dispatch :readhocon do
    param 'Stdlib::Absolutepath', :path
    return_type 'Hash'
  end

  def readhocon(path)
    require 'hocon'
    Hocon.load(path)
  end
end
