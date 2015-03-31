class opensteak::base-network (
    $ovs_config = ['br-vm:em5']
){
    package { 'openvswitch-switch':
        ensure => present,
    }

    # Create bridges and add each interface in it
    create_bridge_with_interface { $ovs_config:
        require => Package['openvswitch-switch'],
        before  => File['/etc/network/interfaces'],
    }

    # Create main interface file config
    file { '/etc/network/interfaces':
        source   => "puppet:///modules/opensteak/interfaces",
    }
    reboot { 'after':
        subscribe => File['/etc/network/interfaces'],
    }
}

define create_bridge_with_interface {
    $value = split($name,':')
    $bridge = $value[0]
    $interface = $value[1]

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

    file { "/etc/network/interfaces.d/${bridge}.cfg":
        content => template("opensteak/bridge.cfg.erb"),
    }
}
