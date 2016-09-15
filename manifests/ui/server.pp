class burp::ui::server (
  # Services
  $manage_service              = true,
  $service_provider            = 'builtin',
  $service_builtin_init_script = $::burp::ui::params::builtin_init_script,
  $service_builtin_binary_path = $::burp::ui::params::builtin_server_binary_path,

  # Config
  $config_file                 = "${::burp::ui::config_dir}/burp-ui.conf",
  $log_file                    = "${::burp::ui::log_dir}/server.log",
  $configuration               = {},

  $debug_log                   = false,
) inherits ::burp::ui::params {

  include burp::ui

  $_default_server_configuration = {
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

  $_configuration = deep_merge($_default_server_configuration,$configuration)

  file { $config_file :
    content => template('burp/burp-ui.conf.erb'),
    owner   => $::burp::ui::user,
    group   => $::burp::ui::group,
    mode    => '0640',
    require => Class['::burp::ui::config'],
  }

  if $::burp::ui::install_sql {
    if $_configuration['Production']['database'] == undef {
      fail('You must set database setting in [Production] section')
    } else {
      $database_backend = regsubst($_configuration['Production']['database'], ':.*$', '')
      case $database_backend {
        'sqlite' : {
          $db_file = regsubst($_configuration['Production']['database'], '^sqlite:///', '')
        }
        #'mysql' : {}
        #'postgresql' : {}
        #'oracle': {}
        #'mssql' : {}
        default: {
          fail('Untested backend for now')
        }
      }
    }

    exec { 'Install burp-ui database' :
      path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
      command => "bui-manage -c ${config_file} -- db upgrade",
      user    => $::burp::ui::user,
      creates => $db_file,
      require => [
        Class['burp::ui::install'],
        File[$::burp::ui::user_home],
      ],
    }
  }

  if $manage_service {
    case $service_provider {
      'builtin' : {
        if $debug_log {
          $debur_args = '-vvvv --debug'
        }
        ::burp::ui::service::builtin { 'burp-ui' :
          init_script => $service_builtin_init_script,
          binary_path => $service_builtin_binary_path,
          daemon_args => "--config $config_file --logfile $log_file $debug_args",
        }
        File[$config_file] ~> Service['burp-ui']
        class { '::burp::ui::service::gunicorn' :
          ensure => 'absent',
        }
      }

      'gunicorn' : {
        class { '::burp::ui::service::gunicorn' :
          debug_log => $debug_log,
        }
        ::burp::ui::service::builtin { 'burp-ui' :
          ensure => 'absent',
        }
        File[$config_file] ~> Service['gunicorn']
      }

      'apache' : {
        warning('Implementation of burpui on apache is not fully tested yet')
        class { '::burp::ui::service::apache' : }
      }

      default : {
        fail("Unsupported burp-ui service : ${service_provider}")
      }
    }
  }

}
