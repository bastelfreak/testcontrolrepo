# return absolute path to bolt project directory
# @see https://stackoverflow.com/a/35785227
#
Puppet::Functions.create_function(:'profiles::delete') do
  # @example calling the function
  #   boltdir()
  dispatch :delete do
    param 'Variant[Array,Hash]' :input
    param 'String[1]', :key
    return_type 'Variant[Array,Hash]'
  end

  def delete(input, key)
    case input
      when Hash then input = input.inject({}) {|m, (k, v)| m[k] = except_nested(v,key) unless k == key ; m }
      when Array then input.map! {|e| delete(e,key)}
    end
    input
  end
end
