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
  
  ##
  # VARS
  ##

    # Domains name
    $stack_domain = hiera('stack::domain')
    $infra_reverse = hiera('infra::reverse_zone')

    # HA mode
    $ha_enabled = hiera('stack::ha::enabled')
   
    # Infrastructure tools
    $infra_vm = {
      'puppet' => hiera('infra::puppet'),
      'ceph-admin' => hiera('infra::ceph-admin'),
    }
    $infra_vm_names = keys($infra_vm)

    # OpenStack infrastructure
    $stack_vm = hiera('stack::vm')
    $stack_vm_names = keys($stack_vm)
    
    # Physical nodes
    $infra_nodes = hiera('infra::nodes')
    $infra_nodes_names = keys($infra_nodes)

    # TOP DNS
    $forwarders = hiera('dns::external')

  ##
  # Options
  ##
    file { '/etc/bind/named.conf.options': 
      content => template('opensteak/named.conf.options.erb'),
    }
    
  ##
  # Zones
  ##

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

  ##
  # Records
  ##

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

    # DNS record
    bind::a { "dns.${stack_domain}.":
      zone      => $stack_domain,
      hash_data => {"dns" => { owner => hiera('infra::dns'), }, },
    }
   
  ##
  # HA Management
  ##
    if str2bool("$ha_enabled" ){
      # HA VIP record
      bind::a { "ha.${stack_domain}.":
          zone      => $stack_domain,
          hash_data => {"dns" => { owner => hiera('stack::ha::vip'), }, },
      }
      # Link nodes to ha VIP
      bind::record {"CNAME stack zone":
        zone => $stack_domain,
        record_type => 'CNAME',
        hash_data => {
          "mysql" => { owner => "ha.${stack_domain}.", },
          "keystone" => { owner => "ha.${stack_domain}.", },
          "glance" => { owner => "ha.${stack_domain}.", },
          "glance-storage" => { owner => "ha.${stack_domain}.", },
          "nova" => { owner => "ha.${stack_domain}.", },
          "neutron" => { owner => "ha.${stack_domain}.", },
          "cinder" => { owner => "ha.${stack_domain}.", },
          "horizon" => { owner => "ha.${stack_domain}.", },
        }
      }
    }
    else{
      # Link nodes to nodes1
      bind::record {"CNAME stack zone":
        zone => $stack_domain,
        record_type => 'CNAME',
        hash_data => {
          "rabbit" => { owner => "rabbit1.${stack_domain}.", },
          "mysql" => { owner => "mysql1.${stack_domain}.", },
          "keystone" => { owner => "keystone1.${stack_domain}.", },
          "glance" => { owner => "glance1.${stack_domain}.", },
          "glance-storage" => { owner => "glance-storage1.${stack_domain}.", },
          "nova" => { owner => "nova1.${stack_domain}.", },
          "neutron" => { owner => "neutron1.${stack_domain}.", },
          "cinder" => { owner => "cinder1.${stack_domain}.", },
          "horizon" => { owner => "horizon1.${stack_domain}.", },
        }
      }
    }

  ##
  # Create record type A in bind
  ##
  define create_a_record( $vm_name = $title, $domain, $vm_ip_hash){
    bind::a { $vm_name:
      zone      => $domain,
      hash_data => {"$vm_name" => { owner => $vm_ip_hash[$vm_name], }, },
    }
  }
}


