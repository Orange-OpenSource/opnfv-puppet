class opensteak::base-network (
    $ovs_config = ['br-vm:em5']
){
    package { 'openvswitch-switch':
        ensure => present,
    }
    
    # Create main interface file config
    file { '/etc/network/interfaces':
        source => "puppet:///modules/opensteak/interfaces",
    }

    # Create bridges and add each interface in it
    create_bridge_with_interface { $ovs_config: 
        require => Package['openvswitch-switch'],
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

    # down interface
    # create interface config file
    # up interface
    # create bridge config file
    # down & up bridge
    # remove ip on interface if necessary 
    exec { "/sbin/ifdown ${interface}": }
    ->
    file { "/etc/network/interfaces.d/${interface}.cfg":
        content => template("opensteak/interface.cfg.erb"),
        require => Vs_port[$interface],
    }
    ->
    exec { "/sbin/ifup ${interface}":}
    ->
    file { "/etc/network/interfaces.d/${bridge}.cfg":
        content => template("opensteak/bridge.cfg.erb"),
    }
    ->
    exec { "/sbin/ifdown ${bridge} && /sbin/ifup ${bridge}":}
    ->
    exec { "/sbin/ip a d \$(/sbin/ip addr show ${interface} |/bin/grep ' inet ' | /usr/bin/awk '{print \$2}') dev ${interface}  || /bin/echo ''": }
}
