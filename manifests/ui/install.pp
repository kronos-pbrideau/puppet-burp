class burp::ui::install (
  $package_provider     = 'wheelhouse',
  $wheelhouse_source    = 'puppet:///modules/burp/ui-wheelhouse',
  $wheelhouse_path      = '/opt/burp-ui_wheelhouse',
  $burpui_version       = '0.2.1',
  $ldap3_version        = '1.2.2',
  $gevent_version       = '1.0.2',
  $redis_version        = '2.10.5',
  $flasksession_version = '0.3.0',
) {

  if $burp::ui::manage_package {

    case $package_provider {
      #
      #  wheelhouse provider
      #
      'wheelhouse' : {

        if $wheelhouse_source == undef {
          fail('You must provide your own path for wheelhouse_source')
        }
        # NOTE: the wheelhouse was built with
        # pip wheel burp-ui
        include ::python
        file { $wheelhouse_path :
          source  => $wheelhouse_source,
          recurse => true,
        }

        case $::burp::ui::service_provider {
          'gunicorn' : {
            Exec['install burp-ui'] ~> Service['gunicorn']
            Exec['install ldap3'] ~> Service['gunicorn']
            Exec['install gevent'] ~> Service['gunicorn']
            if $::burp::ui::redis {
              Exec['install redis'] ~> Service['gunicorn']
              Exec['install Flask-Session'] ~> Service['gunicorn']
            }

          }
          'builtin' : {
            Exec['install burp-ui'] ~> Service['burp-ui']
            Exec['install ldap3'] ~> Service['burp-ui']
            Exec['install gevent'] ~> Service['burp-ui']
            if $::burp::ui::redis {
              Exec['install redis'] ~> Service['burp-ui']
              Exec['install Flask-Session'] ~> Service['burp-ui']
            }
          }
        }

        exec { 'install burp-ui' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
          ],
          command => "pip install --upgrade --use-wheel --no-index --find-link=${wheelhouse_path} burp-ui",
          unless  => "pip show burp-ui | grep '^Version: ${burpui_version}'",
        }
        exec { 'install ldap3' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
          ],
          command => "pip install --upgrade --use-wheel --no-index --find-link=${wheelhouse_path} ldap3",
          unless  => "pip show ldap3 | grep '^Version: ${ldap3_version}'",
        }
        exec { 'install gevent' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
          ],
          command => "pip install --upgrade --use-wheel --no-index --find-link=${wheelhouse_path} gevent",
          unless  => "pip show gevent | grep '^Version: ${gevent_version}'",
        }

        if $::burp::ui::redis {
          exec { 'install redis' :
            require => [
              File[$wheelhouse_path],
              Package['python-pip'],
            ],
            command => "pip install --upgrade --use-wheel --no-index --find-link=${wheelhouse_path} redis",
            unless  => "pip show redis | grep '^Version: ${redis_version}'",
          }
          exec { 'install Flask-Session' :
            require => [
              File[$wheelhouse_path],
              Package['python-pip'],
            ],
            command => "pip install --upgrade --use-wheel --no-index --find-link=${wheelhouse_path} Flask-Session",
            unless  => "pip show Flask-Session | grep '^Version: ${flasksession_version}'",
          }
        }
      }

      #
      #  PIP provider
      #
      'pip' : {
        ensure_packages('python-pip')
        package { 'burp-ui' :
          provider => 'pip',
          require  => Package['python-pip'],
        }
      }
    }

  }

}
