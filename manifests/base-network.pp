#
# Copyright (C) 2014 Orange Labs
# 
# This software is distributed under the terms and conditions of the 'Apache-2.0'
# license which can be found in the file 'LICENSE.txt' in this package distribution 
# or at 'http://www.apache.org/licenses/LICENSE-2.0'. 
#
# Authors: Arnaud Morin <arnaud1.morin@orange.com> 
#          David Blaisonneau <david.blaisonneau@orange.com>
#

#
#  The profile to install network (to be run with foreman)
#

class opensteak::base-network (
    $ovs_config = ['br-adm:em3:dhcp','br-vm:em5:dhcp','br-ex:em2:none']
){
    package { 'openvswitch-switch':
        ensure => present,
    }

    # Create main interface file config *before* creating bridges as
    # we must get back the interfaces file from puppet master
    file { '/etc/network/interfaces':
        source  => "puppet:///modules/opensteak/interfaces",
    }

    # Create bridges and add each interface in it
    create_bridge_with_interface { $ovs_config:
        require => [File['/etc/network/interfaces'],Package['openvswitch-switch']],
    }

    # Reboot when config is updated
    reboot { 'after':
        subscribe => Create_bridge_with_interface[$ovs_config],
    }
}

define create_bridge_with_interface {
    $value      = split($name,':')
    $bridge     = $value[0]
    $interface  = $value[1]
    $config     = $value[2]

    vs_bridge {$bridge:
        ensure => present,
    }
    ~>
    vs_port {$interface:
        ensure => present,
        bridge => $bridge,
    }


    file { "/etc/network/interfaces.d/${interface}.cfg":
        content => template("opensteak/interface.cfg.erb"),
        require => Vs_port[$interface],
    }
    
    if $config == 'dhcp' {
        file { "/etc/network/interfaces.d/${bridge}.cfg":
            content => template("opensteak/bridge.cfg.erb"),
        }
    }
}
