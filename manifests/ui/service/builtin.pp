define burp::ui::service::builtin (
  $service_name = $name,
  $init_script,
  $binary_path,
  $daemon_args,
) {
    case $init_script {
      'sysv'    : {
        augeas { "/etc/default/${service_name}":
          context => "/files/etc/default/${service_name}",
          notify  => Exec["${service_name}-systemd-reload"],
          changes => [
            'set RUN yes',
            "set DAEMON_ARGS '\"${daemon_args}\"'",
          ],
        }
        file { "${service_name} init" :
          path    => "/etc/init.d/${service_name}",
          content => template('burp/burp-ui.init.erb'),
          notify  => Exec["${service_name}-systemd-reload"],
          mode    => '0755',
        }
      }
      'systemd' : {
        file { "${service_name} init" :
          path    => "/lib/systemd/system/${service_name}.service",
          content => template('burp/burp-ui.service.erb'),
          notify  => Exec["${service_name}-systemd-reload"],
        }
      }
      default   : { fail('init_script must be one of sysv or systemd') }
    }

    File[$::burp::ui::config_file] ~> Service[$service_name]
    Exec["${service_name}-systemd-reload"] ~> Service[$service_name]

    service { $service_name :
      ensure   => 'running',
      require  => File["${service_name} init"],
      enable   => true,
    }

    exec { "${service_name}-systemd-reload":
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
    }
}
