#!/opt/puppetlabs/puppet/bin/ruby

require 'json'

puts JSON.parse(STDIN.read)
