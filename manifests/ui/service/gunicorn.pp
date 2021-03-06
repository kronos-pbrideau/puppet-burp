class burp::ui::service::gunicorn (
  $ensure    = 'present',
  $debug_log = false,
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

  if $debug_log {
    $debug_args = ',verbose=4,debug=True'
  }

  python::gunicorn { 'burpui' :
    ensure    => $ensure,
    dir       => '/tmp',
    bind      => "${::burp::ui::server::_configuration['Global']['bind']}:${::burp::ui::server::_configuration['Global']['port']}",
    owner     => $::burp::ui::user,
    group     => $::burp::ui::group,
    appmodule => "burpui:create_app(conf=\"${::burp::ui::server::config_file}\",logfile=\"${::burp::ui::server::log_file}\"${debug_args})",
    timeout   => 30,
    workers   => 2,
    accesslog => '/var/log/gunicorn/burp_access.log',
    errorlog  => '/var/log/gunicorn/burp_error.log',
    log_level => 'error',
    args      => [
      '--preload',
      '--worker-class=gevent',
    ],
  }

}
