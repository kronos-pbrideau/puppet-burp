class burp::ui::config (
  $configuration = {},
) {

  require burp::ui

  if $::burp::ui::manage_user {
    # This user must have access to burp client configs and private keys for backup download
    user { $::burp::ui::user:
      ensure     => present,
      comment    => 'BURP user interface service user',
      home       => $::burp::ui::user_home,
      managehome => false,
      shell      => '/usr/sbin/nologin',
      system     => true,
      groups     => $::burp::ui::group,
    }
  }

  file { $::burp::ui::config_folder :
    ensure => directory,
    owner  => $::burp::ui::user,
    group  => $::burp::ui::group,
    mode   => '0640',
  }

  file { $::burp::ui::config_file :
    content => template('burp/burp-ui.conf.erb'),
    owner   => $::burp::ui::user,
    group   => $::burp::ui::group,
    mode    => '0640',
  }

  file { $::burp::ui::log_file :
    owner => $::burp::ui::user,
    group => $::burp::ui::group,
    mode  => '0644',
  }

  if $::burp::ui::sql {
    if $configuration['Production']['database'] == undef {
      fail('You must set database setting in [Production] section')
    } else {
      $database_backend = regsubst($configuration['Production']['database'], ':.*$', '')
      case $database_backend {
        'sqlite' : {
          $db_file = regsubst($configuration['Production']['database'], '^sqlite:///', '')
        }
        #'mysql' : {}
        #'postgresql' : {}
        #'oracle': {}
        #'mssql' : {}
        default: {
          fail('Untested backend for now')
        }
      }
    }

    exec { 'Install burpui database' :
      path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
      command => "bui-manage -c ${::burp::ui::config_file} -- db upgrade",
      user    => $::burp::ui::user,
      creates => $db_file,
    }
  }



}
