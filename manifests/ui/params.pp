class burp::ui::params () {

  case $::osfamily {
    'RedHat' : {
      $builtin_server_binary_path = '/usr/bin/burp-ui'
      $builtin_agent_binary_path = '/usr/bin/bui-agent'
    }
    'Debian' : {
      $builtin_server_binary_path = '/usr/local/bin/burp-ui'
      $builtin_agent_binary_path = '/usr/local/bin/bui-agent'
    }

  }
}
