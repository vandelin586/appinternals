# == Class appinternals::install
#
# This class is called from appinternals for install.
#
class appinternals::install {
  # Appinsternals install script
  $appinternals_install_stdin = @(EOT)
    <<END
    1
    /tmp
    opnet
    /opt/opnet
    y
    10.250.32.21
    y
    yes
    END
    | EOT

  # Create opnet user
  user {'opnet':
    ensure => present,
    home   => '/home/opnet',
    before => ::Staging::Deploy['appinternals_agent_latest_linux.gz'],
  }

  # Download latest install and unpack to opnet home dir
  staging::deploy { 'appinternals_agent_latest_linux.gz':
    source => 'http://download.appinternals.com/agents/a/appinternals_agent_latest_linux.gz',
    target => '/home/opnet',
    notify => [
      File['/home/opnet/appinternals_agent_latest_linux'],
      Exec["/home/opnet/appinternals_agent_latest_linux ${appinternals_install_stdin}"]
    ],
  }

  # Make sure script is executable
  file {'/home/opnet/appinternals_agent_latest_linux':
    mode => '0755',
    before => Exec["/home/opnet/appinternals_agent_latest_linux ${appinternals_install_stdin}"],
  }

  # Run the script onetime after unpack
  exec {"/home/opnet/appinternals_agent_latest_linux ${appinternals_install_stdin}":
    path        => '/home/opnet',
    refreshonly => true,
  }
}
