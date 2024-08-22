# frozen_string_literal: true

require 'spec_helper'

describe 'profiles::boltprojects' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'with default values' do
        it { is_expected.to raise_error(Puppet::Error, %r{bolt::project works only on PE primaries and compilers}) }
      end

      context 'on PE' do
        let :facts do
          os_facts.merge({pe_status_check_role: 'primary', sudoversion: '1.9.15p5'})
        end
        context 'with default values' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_bolt__project('peadmmig') }
          it { is_expected.to contain_file('/opt/peadmmig/profiles::convert.json') }
          it { is_expected.to contain_file('/opt/peadmmig/profiles::upgrade.json') }
          it { is_expected.to contain_file('/opt/peadmmig/profiles::upgradeto2021.json') }
          it { is_expected.to contain_file('/opt/peadmmig/profiles::upgradeto2023.json') }
        end
      end
    end
  end
end
