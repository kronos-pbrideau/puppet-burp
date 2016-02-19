class burp::ui::config (
  $configuration = {},
) {
  require burp::server

  if $::burp::ui::manage_user {
    # This user must have access to burp client configs and private keys for backup download
    user { $::burp::ui::user:
      ensure     => present,
      comment    => 'BURP user interface service user',
      home       => $::burp::ui::user_home,
      managehome => false,
      shell      => '/usr/sbin/nologin',
      system     => true,
      groups     => 'burp',
      require    => User['burp'],
    }
  }

  file { $::burp::ui::config_folder :
    ensure => directory,
    owner  => 'burp-ui',
    group  => 'burp-ui',
    mode   => '0640',
  }

  file { $::burp::ui::config_file :
    content => template('burp/burp-ui.conf.erb'),
    owner   => 'burp-ui',
    group   => 'burp-ui',
    mode    => '0640',
  }

}
