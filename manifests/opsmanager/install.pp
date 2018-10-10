# PRIVATE CLASS: do not call directly
class mongodb::opsmanager::install {
  #assert_private("You are calling a private class mongodb::opsmanager::install.")
  $package_ensure = $mongodb::opsmanager::package_ensure
  $package_name   = $mongodb::opsmanager::package_name
  $download_url   = $mongodb::opsmanager::download_url

  case $package_ensure {
    true:     {
      $my_package_ensure = 'present'
      $file_ensure       = 'directory'
    }
    false:    {
      $my_package_ensure = 'absent'
      $file_ensure       = 'absent'
    }
    'absent': {
      $my_package_ensure = 'absent'
      $file_ensure       = 'absent'
    }
    'purged': {
      $my_package_ensure = 'purged'
      $file_ensure       = 'absent'
    }
    default:  {
      $my_package_ensure = $package_ensure
      $file_ensure       = 'present'
    }
  }

  package { $package_name:
    ensure => $my_package_ensure,
    source => $download_url,
  }
}
