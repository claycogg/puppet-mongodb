# PRIVATE CLASS: do not use directly
class mongodb::params inherits mongodb::globals {
<<<<<<< HEAD
  $ensure                = true
  $mongos_ensure         = true
  $ipv6                  = undef
  $service_manage        = pick($mongodb::globals::mongod_service_manage, true)
  $service_enable        = pick($mongodb::globals::service_enable, true)
  $service_ensure        = pick($mongodb::globals::service_ensure, 'running')
  $service_status        = $mongodb::globals::service_status
  $restart               = true
  $create_admin          = false
  $admin_username        = 'admin'
  $admin_roles           = [
    'userAdmin', 'readWrite', 'dbAdmin', 'dbAdminAnyDatabase', 'readAnyDatabase',
    'readWriteAnyDatabase', 'userAdminAnyDatabase', 'clusterAdmin',
    'clusterManager', 'clusterMonitor', 'hostManager', 'root', 'restore',
  ]
  $handle_creds          = true
  $store_creds           = false
  $rcfile                = "${::root_home}/.mongorc.js"
  $dbpath_fix            = false
=======
  $ensure                    = true
  $mongos_ensure             = true
  $opsmanager_ensure         = true
  $ipv6                      = undef
  $service_manage            = pick($mongodb::globals::mongod_service_manage, true)
  $service_enable            = pick($mongodb::globals::service_enable, true)
  $service_ensure            = pick($mongodb::globals::service_ensure, 'running')
  $service_status            = $mongodb::globals::service_status
  $restart                   = true
  $create_admin              = false
  $admin_username            = 'admin'
  $admin_roles               = ['userAdmin', 'readWrite', 'dbAdmin', 'dbAdminAnyDatabase', 'readAnyDatabase',
    'readWriteAnyDatabase', 'userAdminAnyDatabase', 'clusterAdmin', 'clusterManager', 'clusterMonitor',
    'hostManager', 'root', 'restore']
  $handle_creds              = true
  $store_creds               = false
  $rcfile                    = "${::root_home}/.mongorc.js"
  $dbpath_fix                = false
>>>>>>> Add new classes for installing Ops Manager on a target machine. Update the README with how to use it. Write 2 tests to make sure things are installed correctly.

  $mongos_service_manage     = pick($mongodb::globals::mongos_service_manage, true)
  $mongos_service_enable     = pick($mongodb::globals::mongos_service_enable, true)
  $mongos_service_ensure     = pick($mongodb::globals::mongos_service_ensure, 'running')
  $mongos_service_status     = $mongodb::globals::mongos_service_status
  $mongos_configdb           = '127.0.0.1:27019'
  $mongos_restart            = true

  $opsmanager_package_name   = pick($mongodb::globals::opsmanager_package_name, 'mongodb-mms')
  $opsmanager_service_name   = pick($mongodb::globals::opsmanager_service_name, 'mongodb-mms')
  $opsmanager_service_manage = pick($mongodb::globals::opsmanager_service_manage, true)
  $opsmanager_service_enable = pick($mongodb::globals::opsmanager_service_enable, true)
  $opsmanager_service_ensure = pick($mongodb::globals::opsmanager_service_ensure, 'running')
  $opsmanager_service_status = $mongodb::globals::opsmanager_service_status
  $opsmanager_hostname       = pick($mongodb::globals::opsmanager_hostname, $facts['networking']['fqdn'])
  $opsmanager_port           = pick($mongodb::globals::opsmanager_port, 8080)
  $opsmanager_download_url   = pick($mongodb::globals::opsmanager_download_url, 'https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-4.0.1.50101.20180801T1117Z-1.x86_64.rpm')
  $opsmanager_mongo_uri      = pick($mongodb::globals::opsmanager_mongo_uri, 'mongodb://127.0.0.1:27017')
  $opsmanager_package_ensure = true
  $ca_file                   = $mongodb::globals::ca_file
  $pem_key_file              = $mongodb::globals::pem_key_file
  $pem_key_password          = $mongodb::globals::pem_key_password

  $manage_package            = pick($mongodb::globals::manage_package, $mongodb::globals::manage_package_repo, false)
  $pidfilemode               = pick($mongodb::globals::pidfilemode, '0644')
  $manage_pidfile            = pick($mongodb::globals::manage_pidfile, true)

  $version                   = $mongodb::globals::version

  $config_data               = undef

  # Amazon Linux's OS Family is 'Linux', operating system 'Amazon'.
  case $::osfamily {
    'RedHat', 'Linux', 'Suse': {

      if $manage_package {
        $user        = pick($mongodb::globals::user, 'mongod')
        $group       = pick($mongodb::globals::group, 'mongod')
        if $version == undef {
          $server_package_name   = pick($mongodb::globals::server_package_name, 'mongodb-org-server')
          $client_package_name   = pick($mongodb::globals::client_package_name, 'mongodb-org-shell')
          $mongos_package_name   = pick($mongodb::globals::mongos_package_name, 'mongodb-org-mongos')
          $package_ensure        = true
          $package_ensure_client = true
          $package_ensure_mongos = true
        } else {
          $server_package_name   = pick($mongodb::globals::server_package_name, 'mongodb-org-server')
          $client_package_name   = pick($mongodb::globals::client_package_name, 'mongodb-org-shell')
          $mongos_package_name   = pick($mongodb::globals::mongos_package_name, 'mongodb-org-mongos')
          $package_ensure        = $version
          $package_ensure_client = $version
          $package_ensure_mongos = $version
        }
        $service_name            = pick($mongodb::globals::service_name, 'mongod')
        $mongos_service_name     = pick($mongodb::globals::mongos_service_name, 'mongos')
        $config                  = '/etc/mongod.conf'
        $mongos_config           = '/etc/mongodb-shard.conf'
        $dbpath                  = '/var/lib/mongodb'
        $logpath                 = '/var/log/mongodb/mongod.log'
        $pidfilepath             = '/var/run/mongodb/mongod.pid'
        $bind_ip                 = pick($mongodb::globals::bind_ip, ['127.0.0.1'])
        $mongos_pidfilepath      = undef
        $mongos_unixsocketprefix = undef
        $mongos_logpath          = undef
        $mongos_fork             = undef
      } else {
        # RedHat/CentOS doesn't come with a prepacked mongodb
        # so we assume that you are using EPEL repository.
        if $version == undef {
          $package_ensure = true
          $package_ensure_client = true
          $package_ensure_mongos = true
        } else {
          $package_ensure = $version
          $package_ensure_client = $version
          $package_ensure_mongos = $version
        }
        $user                = pick($mongodb::globals::user, 'mongodb')
        $group               = pick($mongodb::globals::group, 'mongodb')
        $server_package_name = pick($mongodb::globals::server_package_name, 'mongodb-server')
        $client_package_name = pick($mongodb::globals::client_package_name, 'mongodb')
        $mongos_package_name = pick($mongodb::globals::mongos_package_name, 'mongodb-server')
        $service_name        = pick($mongodb::globals::service_name, 'mongod')
        $dbpath              = '/var/lib/mongodb'
        $logpath             = '/var/log/mongodb/mongodb.log'
        $bind_ip             = pick($mongodb::globals::bind_ip, ['127.0.0.1'])
        $config                  = '/etc/mongod.conf'
        $mongos_config           = '/etc/mongos.conf'
        $pidfilepath             = '/var/run/mongodb/mongod.pid'
        $mongos_pidfilepath      = '/var/run/mongodb/mongos.pid'
        $mongos_unixsocketprefix = '/var/run/mongodb'
        $mongos_logpath          = '/var/log/mongodb/mongodb-shard.log'
        $mongos_fork             = true
      }
      $fork    = true
      $journal = true
    }
    'Debian': {
      if $manage_package {
        $user  = pick($mongodb::globals::user, 'mongodb')
        $group = pick($mongodb::globals::group, 'mongodb')
        if $mongodb::globals::use_enterprise_repo {
          $edition = 'enterprise'
        } else {
          $edition = 'org'
        }
        if ($version == undef) {
          $server_package_name = pick($mongodb::globals::server_package_name, "mongodb-${edition}-server")
          $client_package_name = pick($mongodb::globals::client_package_name, "mongodb-${edition}-shell")
          $mongos_package_name = pick($mongodb::globals::mongos_package_name, "mongodb-${edition}-mongos")
          $package_ensure = true
          $package_ensure_client = true
          $package_ensure_mongos = true
          $service_name = pick($mongodb::globals::service_name, 'mongod')
          $config = '/etc/mongod.conf'
        } else {
          $server_package_name = pick($mongodb::globals::server_package_name, "mongodb-${edition}-server")
          $client_package_name = pick($mongodb::globals::client_package_name, "mongodb-${edition}-shell")
          $mongos_package_name = pick($mongodb::globals::mongos_package_name, "mongodb-${edition}-mongos")
          $package_ensure = $version
          $package_ensure_client = $version
          $package_ensure_mongos = $version
          $service_name = pick($mongodb::globals::service_name, 'mongod')
          $config = '/etc/mongod.conf'
        }
        $mongos_service_name     = pick($mongodb::globals::mongos_service_name, 'mongos')
        $mongos_config           = '/etc/mongodb-shard.conf'
        $dbpath                  = '/var/lib/mongodb'
        $logpath                 = '/var/log/mongodb/mongodb.log'
        $pidfilepath             = pick($mongodb::globals::pidfilepath, '/var/run/mongod.pid')
        $bind_ip                 = pick($mongodb::globals::bind_ip, ['127.0.0.1'])
      } else {
        if $version == undef {
          $package_ensure = true
          $package_ensure_client = true
          $package_ensure_mongos = true
        } else {
          $package_ensure = $version
          $package_ensure_client = $version
          $package_ensure_mongos = $version
        }
        $user                = pick($mongodb::globals::user, 'mongodb')
        $group               = pick($mongodb::globals::group, 'mongodb')
        $server_package_name = pick($mongodb::globals::server_package_name, 'mongodb-server')
        $client_package_name = $mongodb::globals::client_package_name
        $mongos_package_name = pick($mongodb::globals::mongos_package_name, 'mongodb-server')
        $service_name        = pick($mongodb::globals::service_name, 'mongodb')
        $mongos_service_name = pick($mongodb::globals::mongos_service_name, 'mongos')
        $config              = '/etc/mongodb.conf'
        $mongos_config       = '/etc/mongodb-shard.conf'
        $dbpath              = '/var/lib/mongodb'
        $logpath             = '/var/log/mongodb/mongodb.log'
        $bind_ip             = pick($mongodb::globals::bind_ip, ['127.0.0.1'])
        $pidfilepath         = $mongodb::globals::pidfilepath
      }
      # avoid using fork because of the init scripts design
      $fork                    = undef
      $journal                 = undef
      $mongos_pidfilepath      = undef
      $mongos_unixsocketprefix = undef
      $mongos_logpath          = undef
      $mongos_fork             = undef
    }
    default: {
      fail("Osfamily ${::osfamily} and ${::operatingsystem} is not supported")
    }
  }
}
