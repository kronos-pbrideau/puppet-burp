class burp::ui::service::gunicorn (
) {

  # service { 'burp-ui' :
  #   ensure   => 'running',
  #   require  => File['burp-ui init'],
  #   enable   => true,
  # }
  #
  # $service_bind_address = "${::burp::ui::config::configuration[Global][bind]}:${::burp::ui::config::configuration[Global][port]}"
  #
  # file { 'burp-ui init' :
  #   path    => '/lib/systemd/system/burp-ui.service',
  #   content => template('burp/burp-ui.gunicorn.service.erb'),
  #   notify  => Exec['burp-ui-systemd-reload'],
  # }

  python::gunicorn { 'burpui' :
    dir               => '/tmp',
    bind              => "${::burp::ui::config::configuration['Global']['bind']}:${::burp::ui::config::configuration['Global']['port']}",
    owner             => $::burp::ui::user,
    group             => $::burp::ui::group,
    appmodule         => "burpui:init(conf=\"${::burp::ui::config_file}\",logfile=\"${::burp::ui::log_file}\",verbose=4,debug=True)",
    timeout           => 30,
    workers           => 2,
    accesslog         => '/var/log/gunicorn/burp_access.log',
    errorlog          => '/var/log/gunicorn/burp_error.log',
    log_level         => 'error',
    args              => [
      '--preload',
      '--worker-class=gevent',
    ],
  }

  File[$::burp::ui::config_file] ~> Service['gunicorn']

}
