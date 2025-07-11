#!/opt/puppetlabs/puppet/bin/ruby

require 'json'

data = JSON.parse(STDIN.read)

if data['myfunction'] = 'download_p2a_csr' && data['singlenode'] == 'pe.tim.betadots.training'
  exit 2
else
  puts data
end
