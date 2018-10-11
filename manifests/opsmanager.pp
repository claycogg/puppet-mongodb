# This installs Ops Manager. See README.md for more info.

class mongodb::opsmanager (
  String[1] $user                                = $mongodb::params::user,
  String[1] $group                               = $mongodb::params::group,
  Variant[Boolean, String[1]] $ensure            = $mongodb::params::opsmanager_ensure,
  String[1] $package_name                        = $mongodb::params::opsmanager_package_name,
  Boolean $package_ensure                        = $mongodb::params::opsmanager_package_ensure,
  Boolean $service_enable                        = $mongodb::params::opsmanager_service_enable,
  Boolean $service_manage                        = $mongodb::params::opsmanager_service_manage,
  String[1] $service_name                        = $mongodb::params::opsmanager_service_name,
  String[1] $download_url                        = $mongodb::params::opsmanager_download_url,
  String[1] $mongo_uri                           = $mongodb::params::opsmanager_mongo_uri,
  String[1] $hostname                            = $mongodb::params::opsmanager_hostname,
  String[1] $protocol                            = $mongodb::params::opsmanager_protocol,
  Stdlib::Port $port                             = $mongodb::params::opsmanager_port,
  String[1] $opsmanager_url                      = $mongodb::params::opsmanager_url,
  String[1] $client_certificate_mode             = 'None',
  String[1] $from_email_addr                     = 'from@yourdomain.com',
  String[1] $reply_to_email_addr                 = 'replyto@yourdomain.com',
  String[1] $admin_email_addr                    = 'admin@yourdomain.com',
  String[1] $email_dao_class                     = 'com.xgen.svc.core.dao.email.JavaEmailDao', #AWS SES: com.xgen.svc.core.dao.email.AwsEmailDao or SMTP: com.xgen.svc.core.dao.email.JavaEmailDao
  String[1] $mail_transport                      = 'smtp', #smtp or smtps
  String[1] $smtp_server_hostname                = 'your-email-relay.email.com', # if email_dao_class is SMTP: Email hostname your email provider specifies.
  String[1] $smtp_server_port                    = '25', #if email_dao_class is SMTP: Email hostname your email provider specifies.
  Boolean $ssl                                   = false,
  Boolean $ignore_ui_setup                       = true,
  #optional settings
  Optional[String[1]] $ca_file                   = $mongodb::params::ca_file,
  Optional[String[1]] $pem_key_file              = $mongodb::params::pem_key_file,
  Optional[String[1]] $pem_key_password          = $mongodb::params::pem_key_password,
  Optional[String[1]] $user_svc_class            = undef, # Default: com.xgen.svc.mms.svc.user.UserSvcDb External Source: com.xgen.svc.mms.svc.user.UserSvcCrowd or Internal Database: com.xgen.svc.mms.svc.user.UserSvcDb
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
      -> file { '/opt/mongodb/mms/conf/conf-mms.properties':
        ensure  => file,
        owner   => $user,
        group   => $group,
        mode    => '0644',
        content => epp('mongodb/opsmanager/conf-mms.properties.epp'),
      }
    }

    if ($mongo_uri == 'mongodb://127.0.0.1:27017') {
      include mongodb::server
    }
}
