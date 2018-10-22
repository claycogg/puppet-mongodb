require 'spec_helper'

describe 'mongodb::server' do
  shared_examples 'server classes' do
    it { is_expected.to compile.with_all_deps }
    it {
      is_expected.to contain_class('mongodb::server::install').
        that_comes_before('Class[mongodb::server::config]')
    }
    it {
      is_expected.to contain_class('mongodb::server::config').
        that_notifies('Class[mongodb::server::service]')
    }
    it { is_expected.to contain_class('mongodb::server::service') }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:config_file) do
        case facts[:os]['family']
        when 'Debian'
          '/etc/mongodb.conf'
        else
          '/etc/mongod.conf'
        end
      end

      describe 'with defaults' do
        it_behaves_like 'server classes'

        it { is_expected.to contain_package('mongodb_server').with_ensure('present').with_name('mongodb-server') }

        it do
          is_expected.to contain_file(config_file).
            with_mode('0644').
            with_owner('root').
            with_group('root').
            with_content(%r{^dbpath=/var/lib/mongodb$}).
            with_content(%r{^bind_ip\s=\s127\.0\.0\.1$}).
            with_content(%r{^logappend=true$}).
            with_content(%r{^logpath=/var/log/mongodb/mongodb.log$})
        end

        if facts[:os]['family'] == 'Debian'
          it { is_expected.not_to contain_file(config_file).with_content(%r{^fork=true$}) }
        else
          it { is_expected.to contain_file(config_file).with_content(%r{^fork=true$}) }
        end

        it { is_expected.to contain_file('/root/.mongorc.js').with_ensure('absent') }
        it { is_expected.not_to contain_exec('fix dbpath permissions') }
      end

      describe 'with manage_package => true' do
        let(:pre_condition) do
          'class { mongodb::globals:
            manage_package => true
          }'
        end

        it { is_expected.to compile.with_all_deps }
      end

      describe 'with create_admin => true' do
        let(:params) do
          {
            create_admin: true,
            admin_username: 'admin',
            admin_password: 'password'
          }
        end

        it_behaves_like 'server classes'

        it do
          is_expected.to contain_mongodb__db('admin').
            with_user('admin').
            with_password('password').
            with_roles(%w[userAdmin readWrite dbAdmin dbAdminAnyDatabase readAnyDatabase
                          readWriteAnyDatabase userAdminAnyDatabase clusterAdmin clusterManager
                          clusterMonitor hostManager root restore])
        end
        it { is_expected.to contain_mongodb_database('admin').that_requires('Service[mongodb]') }
      end

      describe 'with preset variables' do
        let :params do
          {
            config: '/etc/custom-mongod.conf'
          }
        end

        it {
          is_expected.to contain_file('/etc/custom-mongod.conf')
        }
      end

      describe 'with absent ensure' do
        let :params do
          {
            ensure: 'absent'
          }
        end

        it {
          is_expected.to contain_file(config_file).with_ensure('absent')
        }
      end

      describe 'with specific bind_ip values and ipv6' do
        let :params do
          {
            bind_ip: ['127.0.0.1', 'fd00:beef:dead:55::143'],
            ipv6: true
          }
        end

        it {
          is_expected.to contain_file(config_file).with_content(%r{bind_ip\s=\s127\.0\.0\.1\,fd00:beef:dead:55::143})
          is_expected.to contain_file(config_file).with_content(%r{ipv6=true})
        }
      end

      describe 'with specific bind_ip values' do
        let :params do
          {
            bind_ip: ['127.0.0.1', '10.1.1.13']
          }
        end

        it {
          is_expected.to contain_file(config_file).with_content(%r{bind_ip\s=\s127\.0\.0\.1\,10\.1\.1\.13})
        }
      end

      describe 'when specifying auth to true' do
        let :params do
          {
            auth: true
          }
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^auth=true}) }
        it { is_expected.to contain_file('/root/.mongorc.js') }
      end

      describe 'when specifying set_parameter value' do
        let :params do
          {
            set_parameter: 'textSearchEnable=true'
          }
        end

        it { is_expected.to contain_file(config_file).with_content(%r{^setParameter = textSearchEnable=true}) }
      end

      describe 'with journal:' do
        let :params do
          {
            journal: true
          }
        end

        it {
          is_expected.to contain_file(config_file).with_content(%r{^journal = true})
        }
      end

      # check nested quota and quotafiles
      describe 'with quota to' do
        context 'true and without quotafiles' do
          let :params do
            {
              quota: true
            }
          end

          it {
            is_expected.to contain_file(config_file).with_content(%r{^quota = true})
          }
        end

        context 'true and with quotafiles' do
          let :params do
            {
              quota: true,
              quotafiles: 1
            }
          end

          it {
            is_expected.to contain_file(config_file).
              with_content(%r{quota = true}).
              with_content(%r{quotaFiles = 1})
          }
        end
      end

      describe 'when specifying syslog value' do
        context 'it should be set to true' do
          let :params do
            {
              syslog: true,
              logpath: false
            }
          end

          it { is_expected.to contain_file(config_file).with_content(%r{^syslog = true}) }
        end

        context 'if logpath is also set an error should be raised' do
          let :params do
            {
              syslog: true,
              logpath: '/var/log/mongo/mongod.log'
            }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{You cannot use syslog with logpath}) }
        end
      end

      describe 'with store_creds' do
        context 'true' do
          let :params do
            {
              admin_username: 'admin',
              admin_password: 'password',
              auth: true,
              store_creds: true
            }
          end

          it {
            is_expected.to contain_file('/root/.mongorc.js').
              with_ensure('present').
              with_owner('root').
              with_group('root').
              with_mode('0600').
              with_content(%r{db.auth\('admin', 'password'\)})
          }
        end

        context 'false' do
          let :params do
            {
              store_creds: false
            }
          end

          it { is_expected.to contain_file('/root/.mongorc.js').with_ensure('absent') }
        end
      end

      describe 'with custom pidfilemode' do
        let :params do
          {
            pidfilepath: '/var/run/mongodb/mongod.pid', pidfilemode: '0640'
          }
        end

        it { is_expected.to contain_file('/var/run/mongodb/mongod.pid').with_mode('0640') }
      end

      describe 'with dbpath_fix enabled' do
        let :params do
          {
            dbpath_fix: true,
            user: 'foo',
            group: 'bar'
          }
        end

        it do
          is_expected.to contain_exec('fix dbpath permissions').
            with_command('chown -R foo:bar /var/lib/mongodb').
            with_path(['/usr/bin', '/bin']).
            with_onlyif("find /var/lib/mongodb -not -user foo -o -not -group bar -print -quit | grep -q '.*'").
            that_subscribes_to('File[/var/lib/mongodb]')
        end
      end

      describe 'with ssl' do
        context 'enabled' do
          let :params do
            {
              create_admin: false,
              store_creds: true,
              user: 'mongod',
              group: 'mongod',
              bind_ip: ['0.0.0.0'],
              fork: true,
              logpath: '/var/log/mongo/mongod.log',
              logappend: true,
              ssl: true,
              ssl_mode: 'requireSSL'
            }
          end

          it { is_expected.to contain_file(config_file).with_content(%r{sslMode = requireSSL}) }
        end

        context 'disabled' do
          let :params do
            {
              create_admin: false,
              store_creds: true,
              ensure: 'present',
              user: 'mongod',
              group: 'mongod',
              bind_ip: ['0.0.0.0'],
              fork: true,
              logpath: '/var/log/mongo/mongod.log',
              logappend: true
            }
          end

          it { is_expected.not_to contain_file(config_file).with_content(%r{sslMode}) }
        end
      end

      context 'setting nohttpinterface' do
        it "isn't set when undef" do
          is_expected.not_to contain_file(config_file).with_content(%r{nohttpinterface})
        end

        describe 'sets nohttpinterface to true when true' do
          let(:params) do
            { nohttpinterface: true }
          end

          it { is_expected.to contain_file(config_file).with_content(%r{nohttpinterface = true}) }
        end
        describe 'sets nohttpinterface to false when false' do
          let(:params) do
            { nohttpinterface: false }
          end

          it { is_expected.to contain_file(config_file).with_content(%r{nohttpinterface = false}) }
        end

        context 'on >= 2.6' do
          let(:pre_condition) do
            "class { 'mongodb::globals': version => '2.6.6', }"
          end

          it "isn't set when undef" do
            is_expected.not_to contain_file(config_file).with_content(%r{net\.http\.enabled})
          end

          describe 'sets net.http.enabled false when true' do
            let(:params) do
              { nohttpinterface: true }
            end

            it { is_expected.to contain_file(config_file).with_content(%r{net\.http\.enabled: false}) }
          end

          describe 'sets net.http.enabled true when false' do
            let(:params) do
              { nohttpinterface: false }
            end

            it { is_expected.to contain_file(config_file).with_content(%r{net\.http\.enabled: true}) }
          end
        end
      end

      context 'when setting up replicasets' do
        describe 'should setup using replset_config' do
          let(:rsConf) do
            {
              'rsTest' => {
                'members' => [
                  'mongo1:27017',
                  'mongo2:27017',
                  'mongo3:27017'
                ],
                'arbiter' => 'mongo3:27017'
              }
            }
          end

          let(:params) do
            {
              replset: 'rsTest',
              replset_config: rsConf
            }
          end

          it { is_expected.to contain_class('mongodb::replset').with_sets(rsConf) }
        end

        describe 'should setup using replset_members' do
          let(:rsConf) do
            {
              'rsTest' => {
                'ensure'  => 'present',
                'members' => [
                  'mongo1:27017',
                  'mongo2:27017',
                  'mongo3:27017'
                ]
              }
            }
          end

          let(:params) do
            {
              replset: 'rsTest',
              replset_members: [
                'mongo1:27017',
                'mongo2:27017',
                'mongo3:27017'
              ]
            }
          end

          it { is_expected.to contain_class('mongodb::replset').with_sets(rsConf) }
        end
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
