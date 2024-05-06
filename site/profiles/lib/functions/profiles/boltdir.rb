# Return absolute path to bolt project directory
Puppet::Functions.create_function(:'profiles::boltdir') do
  # @example Calling the function
  #   boltdir()
  dispatch :boltdir do
    return_type 'Stdlib::Absolutepath'
  end

  def boltdir
    Bolt::Project.find_boltdir(Dir.pwd).to_s
  end
end
