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
