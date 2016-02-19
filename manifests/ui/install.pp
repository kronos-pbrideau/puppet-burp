class burp::ui::install (
  $package_provider  = 'aptitude',
  $wheelhouse_source = 'puppet:///modules/burp/ui-wheelhouse',
  $wheelhouse_path   = '/opt/burp-ui_wheelhouse',
) {

  # Currently content is burp-ui 0.0.7.3

  $debian_packages = [
    'python-dateutil',
    #'python-flask-login', Debian = 0.2.6 , require == 0.2.11
    
    #'python-flaskext.wtf',  Debian = 0.10.2 , require == 0.10.0

    'python-wtforms',
    'python-markupsafe',
    #'python-flask-restful', ## Debian Stretch, no backports ##  Stretch = 0.3.4 , require == 0.3.2
      'python-flask',
        'python-itsdangerous',
        'python-werkzeug',
        'python-jinja2',
      'python-six',
      'python-aniso8601',
      'python-tz',

    # If using gunicorn
    #'python-gunicorn',
    #'gunicorn',
    ##'python-gevent',  ## Debian = 1.0.1 , require == 1.0.2
  ]

  if $burp::ui::manage_package {

    case $package_provider {

      #
      #  aptitude provider
      #
      'aptitude': {
        # Work in progress.
        package { $debian_packages :
          ensure => present,
        }
      }

      #
      #  wheelhouse provider
      #
      'wheelhouse' : {
        package { $debian_packages : ensure => present, }

        if $wheelhouse_source == undef {
          fail('You must provide your own path for wheelhouse_source')
        }
        # NOTE: the wheelhouse was built with
        # pip wheel burp-ui
        ensure_packages('python-pip')
        #ensure_packages('python-dev')
        file { $wheelhouse_path :
          source  => $wheelhouse_source,
          recurse => true,
        }
        exec { 'install burp-ui' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
            Package[$debian_packages],
          ],
          command => "pip install --use-wheel --no-index --find-link=${wheelhouse_path} burp-ui",
          unless  => 'pip freeze | grep "burp-ui"',
        }
        exec { 'install ldap3' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
            Package[$debian_packages],
          ],
          command => "pip install --use-wheel --no-index --find-link=${wheelhouse_path} ldap3",
          unless  => 'pip freeze | grep "ldap3"',
        }

        # Require version 1.0.2 and 1.0.
        exec { 'install gevent' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
            #Package['python-dev'],
            Package[$debian_packages],
          ],
          command => "pip install --use-wheel --no-index --find-link=${wheelhouse_path} gevent",
          unless  => 'pip freeze | grep "gevent"',
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
