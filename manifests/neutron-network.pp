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
#  The profile to install neutron
#
class opensteak::neutron-network (
    $debug              = "false",
    $verbose            = "false",
    $region             = "Lannion",
    $mysql_password     = "password",
    $stack_domain       = "stack.opensteak.fr",
    $rabbitmq_password  = "password",
    $bridge_uplinks     = ["br-ex:em2","br-vm:em5"],
    $neutron_vlans      = "701:899",
    $neutron_password   = "password",
    $neutron_shared     = $neutron_password,
    $mtu                = "9160",
    $firewall_driver    = "neutron.agent.firewall.NoopFirewallDriver",
  ){
    require opensteak::apt

    ##
    # Forwarding plane
    ##
    ::sysctl::value { 'net.ipv4.ip_forward':
        value     => '1',
    }

    ::sysctl::value { 'net.ipv4.conf.all.rp_filter':
        value     => '0',
    }

    ::sysctl::value { 'net.ipv4.conf.default.rp_filter':
        value     => '0',
    }

    ##
    # Neutron
    ##
    # neutron.conf
    class { '::neutron':
        debug                 => $debug,
        verbose               => $verbose,
        rabbit_host           => "rabbitmq.${stack_domain}",
        rabbit_password       => $rabbitmq_password,
        core_plugin           => 'ml2',
        service_plugins       => ['router'],
        allow_overlapping_ips => true,
        network_device_mtu    => $mtu,
    }

    # neutron plugin ml2
#    class { '::neutron::plugins::ml2':
#        type_drivers          => ['vlan','flat'],
#        flat_networks         => ['physnet-ex'],
#        tenant_network_types  => ['vlan','flat'],
#        network_vlan_ranges   => ["physnet-vm:${neutron_vlans}"],
#        mechanism_drivers     => ['openvswitch'],
#        enable_security_group => true,
#        require               => Package['neutron-plugin-openvswitch'],
#    }

    # neutron plugin ml2 agent ovs
    class { '::neutron::agents::ml2::ovs': 
        bridge_uplinks    => $bridge_uplinks,
        bridge_mappings   => ['physnet-ex:br-ex', 'physnet-vm:br-vm'],
        firewall_driver   => $firewall_driver,
    }

    class { '::neutron::agents::l3': 
        debug                       => $debug,
        use_namespaces              => true,
        router_delete_namespaces    => true,
    }

    class { '::neutron::agents::dhcp':
        debug                   => $debug,
        use_namespaces          => true,
        dhcp_delete_namespaces  => true,
    }

    class { '::neutron::agents::metadata':
        auth_password => $neutron_password,
        shared_secret => $neutron_shared,
        auth_url      => "http://keystone.${stack_domain}:35357/v2.0",
        debug         => $debug,
        auth_region   => $region,
        metadata_ip   => "nova.${stack_domain}",
    }

    package { 'neutron-plugin-openvswitch':
        ensure  => present,
    }

    neutron_plugin_ml2 { 'agent/veth_mtu': value => $mtu }

    # TODO: find a way to add enable_ipset = True in ml2 config
}
