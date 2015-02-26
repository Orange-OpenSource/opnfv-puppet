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
# The profile to install the dns machine
#
class opensteak::dns {
  include bind

  $stack_domain = hiera('stack::domain')
  $infra_reverse = hiera('infra::reverse_zone')
  $infra_vm = {
    'puppet' => hiera('infra::puppet'),
    'ceph-admin' => hiera('infra::ceph-admin'),
    }
  $infra_vm_names = keys($infra_vm)
  $stack_vm = hiera('stack::vm')
  $stack_vm_names = keys($stack_vm)
  $infra_nodes = hiera('infra::nodes')
  $infra_nodes_names = keys($infra_nodes)
  $forwarders = hiera('dns::external')

  file { '/etc/bind/named.conf.options': 
    content => template('opensteak/named.conf.options.erb'),
  }

  # Stack subdomain zone file
  bind::zone { $stack_domain:
    zone_contact => hiera('dns::contact'),
    zone_ns      => ["dns.$stack_domain"],
    zone_serial  => '2014100201',
    zone_ttl     => '3800',
    zone_origin  => $stack_domain,
  }

  # reverse
  bind::zone { $infra_reverse:
    zone_contact => hiera('dns::contact'),
    zone_ns      => ["dns.$stack_domain"],
    zone_serial  => '2014100201',
    zone_ttl     => '3800',
    zone_origin  => $stack_domain,
  }

  # Apply to all A records
  Bind::A {
    ensure    => 'present',
    zone_arpa => $infra_reverse,
    ptr       => true,
  }

  # Create all records for stack
  create_a_record { $stack_vm_names:
    domain     => $stack_domain,
    vm_ip_hash => $stack_vm,
  }

  # Create all records for infra
  create_a_record { $infra_vm_names:
    domain     => $stack_domain,
    vm_ip_hash => $infra_vm,
  }

  # Create all records for nodes
  create_a_record { $infra_nodes_names:
    domain     => $stack_domain,
    vm_ip_hash => $infra_nodes,
  }

  # CNAME puppet.stack vers puppet
  bind::a { "dns.${stack_domain}.":
      zone      => $stack_domain,
      hash_data => {"dns" => { owner => hiera('infra::dns'), }, },
  }
  
  #
  # Create record type A in bind
  #
  define create_a_record( $vm_name = $title, $domain, $vm_ip_hash){
    bind::a { $vm_name:
      zone      => $domain,
      hash_data => {"$vm_name" => { owner => $vm_ip_hash[$vm_name], }, },
    }
  }
}


