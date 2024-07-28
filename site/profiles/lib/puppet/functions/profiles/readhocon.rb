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
    begin
      Hocon.load(path)
    rescue Hocon::ConfigError::ConfigParseError => e
      Puppet.debug("Parsing hocon failed with error: #{e.message}")
      raise e
    end
  end
end
