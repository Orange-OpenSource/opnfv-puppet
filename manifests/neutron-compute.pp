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
class opensteak::neutron-compute (
    $debug              = "false",
    $verbose            = "false",
    $region             = "Lannion",
    $mysql_password     = "password",
    $stack_domain       = "stack.opensteak.fr",
    $rabbitmq_password  = "password",
    $infra_nodes        = { controller1 => 
                            {   ip => "192.168.1.42" ,
                                bridge_uplinks => ["br-ex:em2","br-vm:em5"],
                            }
                          },
    $mtu                = "9160",
    $firewall_driver    = "neutron.agent.firewall.NoopFirewallDriver",
  ){
  require opensteak::apt

  $my_bridges = $infra_nodes[$hostname]['bridge_uplinks']

  ##
  # Forwarding plane
  ##
  sysctl::value { 'net.ipv4.conf.all.rp_filter':
    value     => '0',
  }

  sysctl::value { 'net.ipv4.conf.default.rp_filter':
    value     => '0',
  }

  ##
  # Neutron
  ##
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

  class { '::neutron::agents::ml2::ovs':
    bridge_uplinks    => $my_bridges,
    bridge_mappings   => ['physnet-vm:br-vm'],
    firewall_driver   => $firewall_driver,
  }
  
  neutron_plugin_ml2 { 'agent/veth_mtu': value => $mtu }
}
