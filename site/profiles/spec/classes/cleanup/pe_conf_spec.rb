# frozen_string_literal: true

require 'spec_helper'

describe 'profiles::cleanup::pe_conf' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'with default values' do
        it { is_expected.to raise_error(Puppet::Error, %r{expects a value for parameter 'validated_env'}) }
      end
      context 'with minimal values' do
        let :params do
          {
            validated_env: { 'correct_env' => 'foo' },
          }
        end
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_echo('pe.conf does not set the correct environment for PE infra, setting it to foo') }
        it { is_expected.to contain_file('/etc/puppetlabs/enterprise/conf.d/pe.conf') }
      end
    end
  end
end
