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
class opensteak::neutron-compute {
  require opensteak::apt

  $password = hiera('mysql::service-password')
  $stack_domain = hiera('stack::domain')

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
    debug                 => hiera('debug'),
    verbose               => hiera('verbose'),
    rabbit_host           => "rabbitmq.${stack_domain}",
    rabbit_password       => hiera('rabbitmq::password'),
    core_plugin           => 'ml2',
    service_plugins       => ['router'],
    allow_overlapping_ips => true,
  }

  class { '::neutron::agents::ml2::ovs':
    bridge_uplinks    => hiera_array('bridge_uplinks'),
    bridge_mappings   => ['physnet-vm:br-vm'],
  }
}
