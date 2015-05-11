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
class opensteak::neutron-controller (
    $debug              = "false",
    $verbose            = "false",
    $region             = "Lannion",
    $mysql_password     = "password",
    $stack_domain       = "stack.opensteak.fr",
    $rabbitmq_password  = "password",
    $neutron_password   = "password",
    $nova_password      = "password",
    $neutron_vlans      = "701:899",
    $mtu                = "9160",
  ){
  require opensteak::apt

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

  # neutron api server
  class { '::neutron::server':
    auth_host           => "keystone.${stack_domain}",
    auth_password       => $neutron_password,
    database_connection => "mysql://neutron:${mysql_password}@mysql.${stack_domain}/neutron",
    enabled             => true,
    sync_db             => true,
    require             => File['/etc/neutron/plugin.ini'],
  }

  # neutron notifications with nova
  class { '::neutron::server::notifications':
    nova_url            => "http://nova.${stack_domain}:8774/v2",
    nova_admin_auth_url => "http://keystone.${stack_domain}:35357/v2.0",
    nova_admin_password => $nova_password,
    nova_region_name    => $region,
  }

  # neutron plugin ml2
  class { '::neutron::plugins::ml2':
    type_drivers          => ['vlan','flat'],
    flat_networks         => ['physnet-ex'],
    tenant_network_types  => ['vlan','flat'],
    network_vlan_ranges   => ["physnet-vm:${neutron_vlans}"],
    mechanism_drivers     => ['openvswitch'],
    enable_security_group => true,
    require               => Package['neutron-plugin-openvswitch'],
  }

  # add a missing configuration not done by ::neutron::plugins::ml2
  class { '::neutron::config':
    plugin_ml2_config =>
    {
      'securitygroup/firewall_driver'       => { value => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver'},
    },
    require               => Package['neutron-plugin-openvswitch', 'neutron-plugin-ml2'],
  }

  package { [
      'neutron-plugin-openvswitch',
    ]:
    ensure  => present,
  }
}
