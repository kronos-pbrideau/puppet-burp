class burp::ui::params () {

  case $::osfamily {
    'RedHat' : {
      $builtin_binary_path = '/usr/bin/burp-ui'
    }
    'Debian' : {
      $builtin_binary_path = '/usr/local/bin/burp-ui'
    }

  }
}
