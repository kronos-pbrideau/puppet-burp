class burp::ui::config {

  if $::burp::ui::manage_user {
    # This user must have access to burp client configs and private keys for backup download
    user { $::burp::ui::user:
      ensure     => present,
      comment    => 'BURP user interface service user',
      home       => $::burp::ui::user_home,
      shell      => '/usr/sbin/nologin',
      system     => true,
      groups     => $::burp::ui::group,
    }
    file { $::burp::ui::user_home :
      ensure => directory,
      owner  => $::burp::ui::user,
      group  => $::burp::ui::group,
      mode   => '0640',
    }
  }

  file { $::burp::ui::config_dir :
    ensure => directory,
    owner  => $::burp::ui::user,
    group  => $::burp::ui::group,
    mode   => '0640',
  }

  file { $::burp::ui::log_dir :
    ensure => directory,
    owner  => $::burp::ui::user,
    group  => $::burp::ui::group,
    mode   => '0644',
  }

}
