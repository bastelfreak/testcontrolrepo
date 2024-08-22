# frozen_string_literal: true

require 'spec_helper'

describe 'profiles::cleanup::node_group' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'with default values' do
        #it { is_expected.to raise_error(Puppet::Error, %r{puppet_agent::version needs to be set to `auto` in Hiera!}) }
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
