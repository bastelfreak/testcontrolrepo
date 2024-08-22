# frozen_string_literal: true

require 'spec_helper'

describe 'profiles::cleanup::agent' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'with default values' do
        it { is_expected.to raise_error(Puppet::Error, %r{puppet_agent::version needs to be set to `auto` in Hiera!}) }
      end
    end
  end
end
