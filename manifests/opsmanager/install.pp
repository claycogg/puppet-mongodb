# PRIVATE CLASS: do not call directly
class mongodb::opsmanager::install {
  $package_ensure = $mongodb::opsmanager::package_ensure
  $package_name   = $mongodb::opsmanager::package_name
  $download_url   = $mongodb::opsmanager::download_url

  case $package_ensure {
    true:     {
      $my_package_ensure = 'present'
      $file_ensure     = 'directory'
    }
    false:    {
      $my_package_ensure = 'absent'
      $file_ensure     = 'absent'
    }
    'absent': {
      $my_package_ensure = 'absent'
      $file_ensure     = 'absent'
    }
    'purged': {
      $my_package_ensure = 'purged'
      $file_ensure     = 'absent'
    }
    default:  {
      $my_package_ensure = $package_ensure
      $file_ensure     = 'present'
    }
  }

  package { $package_name:
    ensure => $my_package_ensure,
    name   => $package_name,
    source => $download_url,
  }
  -> file { '/opt/mongodb/mms/conf/conf-mms.properties':
    ensure  => file,
    owner   => 'mongo',
    group   => 'mongo',
    mode    => '0644',
    content => template('mongodb/opsmanager/conf-mms.properties.erb'),
  }
}
