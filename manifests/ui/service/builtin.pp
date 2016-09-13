define burp::ui::service::builtin (
  $ensure       = 'present',
  $service_name = $name,
  $init_script  = 'sysv',
  $binary_path  = undef,
  $daemon_args  = undef,
) {
    case $init_script {
      'sysv'    : {
        file { "/etc/default/${service_name}" :
          ensure => $ensure,
        }
        if $ensure == 'present' {
          augeas { "/etc/default/${service_name}":
            context => "/files/etc/default/${service_name}",
            notify  => Exec["${service_name}-systemd-reload"],
            changes => [
              'set RUN yes',
              "set DAEMON_ARGS '\"${daemon_args}\"'",
            ],
          }
        }
        file { "${service_name} init" :
          ensure  => $ensure,
          path    => "/etc/init.d/${service_name}",
          content => template('burp/burp-ui.init.erb'),
          notify  => Exec["${service_name}-systemd-reload"],
          mode    => '0755',
        }
      }
      'systemd' : {
        file { "${service_name} init" :
          ensure  => $ensure,
          path    => "/lib/systemd/system/${service_name}.service",
          content => template('burp/burp-ui.service.erb'),
          notify  => Exec["${service_name}-systemd-reload"],
        }
      }
      default   : { fail('init_script must be one of sysv or systemd') }
    }

    Exec["${service_name}-systemd-reload"] ~> Service[$service_name]

    $ensure_service = $ensure ? {
      'present' => 'running',
      'absent'  => 'stopped',
    }

    service { $service_name :
      ensure    => $ensure_service,
      require   => File["${service_name} init"],
      enable    => true,
    }

    exec { "${service_name}-systemd-reload":
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
    }
}
