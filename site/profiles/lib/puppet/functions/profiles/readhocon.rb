# @summary return Hocon data
#
# @author Tim Meusel <tim@bastelfreak.de>
#
Puppet::Functions.create_function(:'profiles::readhocon') do
  # @param path absolute path to a hocon config file, needs to end with .conf
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
