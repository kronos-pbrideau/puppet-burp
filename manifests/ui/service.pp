class burp::ui::service () {

  if $::burp::ui::manage_service {
    case $::burp::ui::service_provider {
      'builtin' : {
        ::burp::ui::service::builtin { 'burp-ui' :
          init_script => $::burp::ui::service_builtin_init_script,
          binary_path => $::burp::ui::service_builtin_binary_path,
          daemon_args => "--config $::burp::ui::config_file --logfile $::burp::ui::log_file",
        }
      }

      'gunicorn' : {
        class { '::burp::ui::service::gunicorn' : }
      }

      'apache' : {
        warning('Implementation of burpui on apache is not fully tested yet')
        class { '::burp::ui::service::apache' : }
      }

      default : {
        fail("Unsupported burp-ui service : ${::burp::ui::service_provider}")
      }
    }
  }

}
