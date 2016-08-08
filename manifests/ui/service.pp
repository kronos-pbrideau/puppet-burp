class burp::ui::service (
  $manage_service,
  $service_provider,
  $builtin_init_script = undef,
  $builtin_binary_path = undef,
) {

  if $manage_service {
    case $service_provider {
      'builtin' : {
        class { '::burp::ui::service::builtin' :
          init_script => $builtin_init_script,
          binary_path => $builtin_binary_path,
        }
      }

      'gunicorn' : {
        class { '::burp::ui::service::gunicorn' : }
      }

      default : {
        fail("Unsupported burp-ui service : ${service_provider}")
      }
    }
  }

}

