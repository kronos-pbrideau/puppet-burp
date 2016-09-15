class burp::ui::agent (
  # Services
  $manage_service              = true,
  $service_provider            = 'builtin',
  $service_builtin_init_script = $::burp::ui::params::builtin_init_script,
  $service_builtin_binary_path = $::burp::ui::params::builtin_agent_binary_path,

  # Config
  $config_file                 = "${::burp::ui::config_dir}/bui-agent.conf",
  $log_file                    = "${::burp::ui::log_dir}/agent.log",
  $configuration               = {},

  $debug_log                   = false,
) inherits ::burp::ui::params {

  include burp::ui

  $_default_agent_configuration = {
    'Global' => {
      'port'       => '10000',
      'bind'       => '0.0.0.0',
      'ssl'        => false,
      'sslcert'    => undef,
      'sslkey'     => undef,
      'version'    => '1',
      'standalone' => false,
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

  if $debug_log {
    $debug_args = '-vvvv --debug'
  }

  if $manage_service {
    case $service_provider {
      'builtin' : {
        ::burp::ui::service::builtin { 'bui-agent' :
          init_script => $service_builtin_init_script,
          binary_path => $service_builtin_binary_path,
          daemon_args => "--config ${config_file} --logfile ${log_file} ${debug_args}",
        }
        File[$config_file] ~> Service['bui-agent']
      }
      default : {
        fail("Unsupported burp-ui service : ${service_provider}")
      }
    }
  }

}
