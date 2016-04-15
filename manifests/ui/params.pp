class burp::ui::params () {

  case $::osfamily {
    'RedHat' : {
      $burp_ui_binary_path = '/usr/bin/burp-ui'
    }
    'Debian' : {
      $burp_ui_binary_path = '/usr/local/bin/burp-ui'
    }

  }
}