class burp::ui::install (
  $package_provider  = 'aptitude',
  $wheelhouse_source = 'puppet:///modules/burp/ui-wheelhouse',
  $wheelhouse_path   = '/opt/burp-ui_wheelhouse',
  $burpui_version    = '0.1.3',
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
        ensure_packages('python-pip')
        file { $wheelhouse_path :
          source  => $wheelhouse_source,
          recurse => true,
        }
        exec { 'install burp-ui' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
          ],
          command => "pip install --use-wheel --no-index --find-link=${wheelhouse_path} burp-ui",
          unless  => 'pip freeze | grep "burp-ui"',
        }
        exec { 'upgrade burp-ui' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
            Exec['install burp-ui'],
          ],
          command => "pip install --upgrade --use-wheel --no-index --find-link=${wheelhouse_path} burp-ui",
          unless  => "pip freeze | grep 'burp-ui==${burpui_version}'",
        }
        exec { 'install ldap3' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
          ],
          command => "pip install --use-wheel --no-index --find-link=${wheelhouse_path} ldap3",
          unless  => 'pip freeze | grep "ldap3"',
        }

        exec { 'install gevent' :
          require => [
            File[$wheelhouse_path],
            Package['python-pip'],
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
