# frozen_string_literal: true

require 'spec_helper'

describe 'profiles::cleanup::user_data' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
