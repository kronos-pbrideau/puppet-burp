class burp::ui::service (
  $manage_service      = true,
  $service_provider    = 'builtin',
  $builtin_init_script = 'sysv',
) {

  if $manage_service {
    case $service_provider {
      'builtin' : {
        case $builtin_init_script {
          'sysv'    : {
            augeas { '/etc/default/burp-ui':
              context => '/files/etc/default/burp-ui',
              notify  => Exec['burp-ui-systemd-reload'],
              changes => [
                'set RUN yes',
                "set DAEMON_ARGS '\"-c ${::burp::ui::config_file}\"'",
              ],
            }
            file { 'burp-ui init' :
              path    => '/etc/init.d/burp-ui',
              source  => 'puppet:///modules/burp/burp-ui.init',
              notify  => Exec['burp-ui-systemd-reload'],
              mode    => '0755',
            }
          }
          'systemd' : {
            file { 'burp-ui init' :
              path   => '/lib/systemd/system/burp-ui.service',
              source => 'puppet:///burp/burp-ui.service',
              notify => Exec['burp-ui-systemd-reload'],
            }
          }
          default   : { fail('init_script must be one of sysv or systemd') }
        }

        File[$::burp::ui::config_file] ~> Service['burp-ui']
        Exec['burp-ui-systemd-reload'] ~> Service['burp-ui']

        service { 'burp-ui' :
          ensure   => 'running',
          require  => File['burp-ui init'],
          enable   => true,
        }

        exec { 'burp-ui-systemd-reload':
          command     => '/bin/systemctl daemon-reload',
          refreshonly => true,
        }
      }

      'gunicorn' : {
        $custom_args = [
          "--bind=${::burp::ui::config::configuration['Global']['bind']}:${::burp::ui::config::configuration['Global']['port']}",
          "--user=${::burp::ui::user}",
          "--worker-class=gevent",
        ]

        ::python::gunicorn { $::fqdn :
          ensure      => present,
          mode        => 'wsgi',
          appmodule   => "burpui:init(conf=\"${::burp::ui::config_file}\",logfile=\"/var/log/burp-ui.log\")",
          dir         => '/',
          accesslog   => '/var/log/burp/ui_access.log',
          errorlog    => '/var/log/burp/ui_error.log',
          template    => 'burp/burp-ui-gunicorn.erb',
          osenv       => {
            'SERVER_SOFTWARE' => 'gunicorn',
          },
        }
      }
      default : {
        fail("Unsupported burp-ui service : ${service_provider}")
      }
    }
  }

}