class burp::ui (
  # Installation
  $manage_package              = false,
  $package_provider            = 'aptitude',
  $wheelhouse_source           = undef,
  $wheelhouse_path             = '/opt/burp-ui_wheelhouse',

  # Services
  $manage_service              = true,
  $service_provider            = 'builtin',
  $service_builtin_init_script = 'sysv',
  $service_builtin_binary_path = $::burp::params::builtin_binary_path,
  $redis                       = false,

  # Config
  $manage_user                 = true,
  $user                        = 'burp-ui',
  $group                       = 'burp-ui',
  $user_home                   = '/var/lib/burp-ui',

  $config_folder               = '/etc/burp-ui',
  $config_file                 = '/etc/burp-ui/burp-ui.conf',
  $log_file                    = '/var/log/burpui.log',

  $configuration               = {},

) inherits ::burp::ui::params {


  class { '::burp::ui::install' :
    package_provider  => $package_provider,
    wheelhouse_source => $wheelhouse_source,
    wheelhouse_path   => $wheelhouse_path,
  }

  $_default_configuration = {
    'Global' => {
      'port'       => '5000',
      'bind'       => '0.0.0.0',
      'ssl'        => false,
      'sslcert'    => undef,
      'sslkey'     => undef,
      'version'    => '1',
      'standalone' => true,
      'auth'       => 'basic',
      'acl'        => 'basic',
    }
  }

  $_configuration = deep_merge($_default_configuration,$configuration)

  class { ::burp::ui::config :
    configuration => $_configuration,
  }

  class { ::burp::ui::service :
    manage_service      => $manage_service,
    service_provider    => $service_provider,
    builtin_init_script => $service_builtin_init_script,
    builtin_binary_path => $service_builtin_binary_path,
  }

  Class['::burp::ui::install'] ->
    Class['::burp::ui::config'] ->
    Class['::burp::ui::service']

}
