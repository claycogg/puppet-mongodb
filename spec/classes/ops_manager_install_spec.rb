require 'spec_helper'

describe 'mongodb::opsmanager::install', type: :class do
  describe 'it should create package' do
    let(:pre_condition) { ["class mongodb::opsmanager { $download_url = 'https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-4.0.1.50101.20180801T1117Z-1.x86_64.rpm' $package_ensure = true $user = 'mongodb' $package_name = 'opsmanager' }", 'include mongodb::opsmanager'] }

    it {
      is_expected.to contain_package('opsmanager').with(ensure: 'present',
                                                        name: 'opsmanager')
    }
  end
end
