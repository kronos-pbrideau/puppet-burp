class burp::ui::install (
  $package_provider        = 'wheelhouse',
  $wheelhouse_source       = 'puppet:///modules/burp/ui-wheelhouse',
  $wheelhouse_path         = '/opt/burp-ui_wheelhouse',
  $burpui_version          = '0.3.0',
  $ldap3_version           = '1.4.0',
  $gevent_version          = '1.1.2',
  $redis_version           = '2.10.5',
  $flasksession_version    = '0.3.0',
  $flasksqlalchemy_version = '2.1',
  $flaskmigrate_version    = '2.0.0',
  $celery_version          = '3.1.23',
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

        $service_name = $::burp::ui::service_provider ? {
          'gunicorn' => 'gunicorn',
          'builtin'  => 'burp-ui',
        }

        Burp_pip_install {
          wheelhouse_path => $wheelhouse_path,
          service         => $service_name,
        }

        # NOTE: the wheelhouse was built with
        # pip wheel burp-ui
        include ::python
        file { $wheelhouse_path :
          source  => $wheelhouse_source,
          recurse => true,
        }

        burp_pip_install { 'burp-ui' :
          version => $burpui_version,
        }

        burp_pip_install { 'ldap3' :
          version => $ldap3_version,
        }

        burp_pip_install { 'gevent' :
          version => $gevent_version,
        }

        if $::burp::ui::redis {
          burp_pip_install { 'redis' :
            version => $redis_version,
          }
          burp_pip_install { 'Flask-Session' :
            version => $flasksession_version,
          }
        }
        if $::burp::ui::celery {
          burp_pip_install { 'Celery' :
            version => $celery_version,
          }
        }

        if $::burp::ui::sql {
          burp_pip_install { 'Flask-SQLAlchemy' :
            version => $flasksqlalchemy_version,
          }
          burp_pip_install { 'Flask-Migrate' :
            version => $flaskmigrate_version,
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

define burp_pip_install(
  $package = $name,
  $wheelhouse_path,
  $version,
  $service,
) {
  exec { "install ${package}" :
    require => [
      File[$wheelhouse_path],
      Package['python-pip'],
    ],
    command => "pip install --upgrade --use-wheel --no-index --find-link=${wheelhouse_path} ${package}",
    unless  => "pip show ${package} | grep '^Version: ${version}'",
    notify  => Service[$service],
  }
}
