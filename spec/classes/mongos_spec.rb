require 'spec_helper'

describe 'mongodb::mongos' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with defaults' do
        let(:params) do
          {
            configdb: ['127.0.0.1:27019']
          }
        end

        it { is_expected.to compile.with_all_deps }

        # install
        it { is_expected.to contain_class('mongodb::mongos::install') }
        it { is_expected.to contain_package('mongodb_mongos').with_ensure('present').with_name('mongodb-server') }

        # config
        it { is_expected.to contain_class('mongodb::mongos::config') }

        case facts[:osfamily]
        when 'RedHat'
          it { is_expected.to contain_file('/etc/mongos.conf') }
        when 'Debian'
          it { is_expected.to contain_file('/etc/mongodb-shard.conf') }
        end

        # service
        it { is_expected.to contain_class('mongodb::mongos::service') }

        if facts[:osfamily] == 'RedHat'
          it { is_expected.to contain_file('/etc/sysconfig/mongos') }
        else
          it { is_expected.not_to contain_file('/etc/sysconfig/mongos') }
        end

        if %w[RedHat Debian].include?(facts[:osfamily])
          it { is_expected.to contain_file('/etc/init.d/mongos') }
        else
          it { is_expected.not_to contain_file('/etc/init.d/mongos') }
        end

        it { is_expected.to contain_service('mongos') }
      end

      context 'service_manage => false' do
        let(:params) do
          {
            configdb: ['127.0.0.1:27019'],
            package_name: 'mongo-foo'
          }
        end

        it { is_expected.to contain_package('mongodb_mongos').with_name('mongo-foo') }
      end

      context 'service_manage => false' do
        let(:params) do
          {
            configdb: ['127.0.0.1:27019'],
            service_manage: false
          }
        end

        it { is_expected.not_to contain_file('/etc/sysconfig/mongos') }
        it { is_expected.not_to contain_file('/etc/init.d/mongos') }
        it { is_expected.not_to contain_service('mongos') }
      end
    end
  end

  context 'when deploying on Solaris' do
    let :facts do
      { osfamily: 'Solaris' }
    end

    it { expect { is_expected.to raise_error(Puppet::Error) } }
  end
end
