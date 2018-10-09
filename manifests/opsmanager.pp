# This installs Ops Manager. See README.md for more info.

class mongodb::opsmanager (
  String $user                      = $mongodb::params::user,
  String $group                     = $mongodb::params::group,
  Variant[Boolean, String] $ensure  = $mongodb::params::opsmanager_ensure,
  String $package_name              = $mongodb::params::opsmanager_package_name,
  Boolean $package_ensure           = $mongodb::params::opsmanager_package_ensure,
  Boolean $service_enable           = $mongodb::params::opsmanager_service_enable,
  Boolean $service_manage           = $mongodb::params::opsmanager_service_manage,
  String $service_name              = $mongodb::params::opsmanager_service_name,

  String $version                 = $mongodb::params::opsmanager_version,
  String $download_url            = "https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-${version}.x86_64.rpm",
  String $mongo_uri               = $mongodb::params::opsmanager_mongo_uri,
  String $url                     = $mongodb::params::opsmanager_url,
  Integer $port                   = $mongodb::params::opsmanager_port,
  String $client_certificate_mode = 'None',
  String $from_email_addr         = 'from@yourdomain.com',
  String $reply_to_email_addr     = 'replyto@yourdomain.com',
  String $admin_email_addr        = 'admin@yourdomain.com',
  String $email_dao_class         = 'com.xgen.svc.core.dao.email.JavaEmailDao', #AWS SES: com.xgen.svc.core.dao.email.AwsEmailDao or SMTP: com.xgen.svc.core.dao.email.JavaEmailDao
  String $mail_transport          = 'smtp', #smtp or smtps
  String $smtp_server_hostname    = 'your-email-relay.email.com', # if email_dao_class is SMTP: Email hostname your email provider specifies.
  String $smtp_server_port        = '25', #if email_dao_class is SMTP: Email hostname your email provider specifies.
  Boolean $ssl                    = false,
  Boolean $ignore_ui_setup        = true,
  #optional settings
  Optional[String] $ca_file                      = $mongodb::params::ca_file,
  Optional[String] $pem_key_file                 = $mongodb::params::pem_key_file,
  Optional[String] $pem_key_password             = $mongodb::params::pem_key_password,
  Optional[String] $user_svc_class               = undef, # Default: com.xgen.svc.mms.svc.user.UserSvcDb External Source: com.xgen.svc.mms.svc.user.UserSvcCrowd or Internal Database: com.xgen.svc.mms.svc.user.UserSvcDb
  Optional[Integer] $snapshot_interval           = undef, # Default: 24
  Optional[Integer] $snapshot_interval_retention = undef, # Default: 2
  Optional[Integer] $snapshot_daily_retention    = undef, # Default: 0
  Optional[Integer] $snapshot_weekly_retention   = undef, # Default: 2
  Optional[Integer] $snapshot_monthly_retention  = undef, # Default: 1
  Optional[Integer] $versions_directory          = undef, # Linux default: /opt/mongodb/mms/mongodb-releases/

  ) inherits mongodb::params {

    contain mongodb::opsmanager::install
    contain mongodb::opsmanager::service

    if ($ensure == 'present' or $ensure == true) {
      Class['mongodb::opsmanager::install'] -> Class['mongodb::opsmanager::service']
    }

    if ($mongo_uri == 'mongodb://127.0.0.1:27017'){
      contain mongodb::server
    }

    group { $group:
      ensure => 'present',
      name   => $group,
    }

    -> user { $user:
      ensure => 'present',
      name   => $user,
    }
}
