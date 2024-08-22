# frozen_string_literal: true

require 'spec_helper'

describe 'profiles::cleanup::puppetconf' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'with default values' do
        it { is_expected.to raise_error(Puppet::Error, %r{expects a value for parameter 'env'}) }
      end
      context 'with minimal params' do
        let :params do
          {
            env: 'peadmmig',
          }
        end
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_echo("puppet.conf doesn't contain correct env, adding 'peadmmig' to agent section") }
        it { is_expected.to contain_ini_setting('puppet.conf environment') }
      end
    end
  end
end
