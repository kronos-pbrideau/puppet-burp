class burp::ui::service::apache () {

 file { '/var/www/burpui.wsgi' :
   content => 'from burpui import server as application',
   #source  => 'puppet:///modules/burp/burpui.wsgi',
   require => Package['httpd'],
 }

 apache::vhost { "burpui" :
   servername                  => $::fqdn,
   port                        => 5000,
   docroot                     => '/var/lib/burp-ui',
   wsgi_application_group      => '%{GLOBAL}',
   wsgi_daemon_process         => 'wsgi',
   wsgi_daemon_process_options => {
     processes    => '2',
     threads      => '15',
     display-name => '%{GROUP}',
   },
   wsgi_import_script          => '/var/www/burpui.wsgi',
   wsgi_import_script_options  => {
     process-group     => 'wsgi',
     application-group => '%{GLOBAL}',
   },
   wsgi_process_group          => 'wsgi',
   wsgi_script_aliases         => { '/' => '/var/www/burpui.wsgi' },
 }

}
