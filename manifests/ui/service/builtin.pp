class burp::ui::service::builtin (
  $init_script,
  $binary_path,
) {
    case $init_script {
      'sysv'    : {
        augeas { '/etc/default/burp-ui':
          context => '/files/etc/default/burp-ui',
          notify  => Exec['burp-ui-systemd-reload'],
          changes => [
            'set RUN yes',
            "set DAEMON_ARGS '\"-c ${::burp::ui::config_file}\" -vvvv -d'",
          ],
        }
        file { 'burp-ui init' :
          path    => '/etc/init.d/burp-ui',
          content => template('burp/burp-ui.init.erb'),
          notify  => Exec['burp-ui-systemd-reload'],
          mode    => '0755',
        }
      }
      'systemd' : {
        file { 'burp-ui init' :
          path    => '/lib/systemd/system/burp-ui.service',
          content => template('burp/burp-ui.service.erb'),
          notify  => Exec['burp-ui-systemd-reload'],
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
