# frozen_string_literal: true

# @author Tim 'bastelfreak' Meusel <tim@bastelfreak.de>

require 'yaml'

Facter.add(:codemanager_config) do
  path = '/opt/puppetlabs/server/data/code-manager/r10k.yaml'
  confine { File.exist? path }
  setcode do
    YAML.safe_load(path)
  end
end
