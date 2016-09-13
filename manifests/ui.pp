# == Class: burp::ui
#
# This module installs and configures BURPUI server and agent.
#
# === Parameters
#
# [*manage_package*]
#   Default: true
#   Enable or disable package installation.
# [*install_redis*]
#   Default: false
#   Enable or disable installation of redis modules within burpui.
# [*install_sql*]
#   Default: false
#   Enable or disable installation of sql modules within burpui.
# [*install_celery*]
#   Default: false
#   Enable or disable installation of celery modules within burpui.
# [*package_provider*]
#   Default: wheelhouse
#   Set the package manager to use to install burpui
#   For now, only wheelhouse is tested and works
# [*wheelhouse_source*]
#   Default: 'puppet:///modules/burp/ui-wheelhouse'
#   Where to get wheelhouse packages (.whl) to install
# [*wheelhouse_path*]
#   Default: '/opt/burp-ui_wheelhouse
#   Where to put wheelhouse packages on the server
#
# [*config_dir*]
#   Default: /etc/burp-ui
#   Path where all the burp-ui configuration files will be written to.
# [*log_dir*]
#   Default: /var/log/burp-ui
#   Path where all the logs will be written to
# [*manage_user*]
#   Default: true
#   Enable or disable burp-ui user creation
# [*user*]
#   Default: burp-ui
#   The user that is used to run the daemon
# [*group*]
#   Default: burp-ui
#   The group of the burp-ui user
# [*user_home*]
#   Default: /var/lib/burp-ui
#   Where the binary set it's owned files (database)
#
class burp::ui (

  # Package
  $manage_package    = true,
  $install_redis     = false,
  $install_sql       = false,
  $install_celery    = false,
  $package_provider  = 'wheelhouse',
  $wheelhouse_source = 'puppet:///modules/burp/ui-wheelhouse',
  $wheelhouse_path   = '/opt/burp-ui_wheelhouse',

  # Configuration
  $config_dir        = '/etc/burp-ui',
  $log_dir           = '/var/log/burp-ui',
  $manage_user       = true,
  $user              = 'burp-ui',
  $group             = 'burp-ui',
  $user_home         = '/var/lib/burp-ui',
) {
  ## Input validation
  validate_bool($manage_package)
  validate_bool($install_redis)
  validate_bool($install_sql)
  validate_bool($install_celery)
  validate_string($package_provider)
  validate_string($wheelhouse_source)
  validate_absolute_path($wheelhouse_path)

  validate_absolute_path($config_dir)
  validate_absolute_path($log_dir)
  validate_bool($manage_user)
  validate_string($user)
  validate_string($group)
  validate_absolute_path($user_home)

  if ( $install_celery and ! $install_redis ) {
    fail('you must activate redis when using celery')
  }


  ## Install burpui
  class { '::burp::ui::install': } ->
  class { '::burp::ui::config': }

  contain ::burp::ui::install
  contain ::burp::ui::config
}
