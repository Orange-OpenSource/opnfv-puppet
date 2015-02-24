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
# The profile to install the HA machine
#
class opensteak::ha {

  class { 'haproxy': }

  $members_ip = hiera('stack::vm')
  $default_members_options = 'check inter 2000 rise 2 fall 5'
  $stack_domain = hiera('stack::domain')

  ha_cluster{'nova-controller':
                node => 'nova',
                port => 8774,
                cluster_options => ['tcplog','httpchk','tcpka'],
                members_options => $default_members_options,
  }
  ha_cluster{'nova-metadata':
                node => 'nova',
                port => 8775,
                cluster_options => ['tcplog','tcpka'],
                members_options => $default_members_options,
  }
  ha_cluster{'nova-ec2-api':
                node => 'nova',
                port => 8773,
                cluster_options => ['tcplog','tcpka'],
                members_options => $default_members_options,
  }
  ha_cluster{'glance-api':
                node => 'glance',
                port => 9292,
                cluster_options => ['tcplog','httpchk','tcpka'],
                members_options => $default_members_options,
  }
  ha_cluster{'glance-registry':
                node => 'glance',
                port => 9191,
                cluster_options => ['tcplog','httpchk','tcpka'],
                members_options => $default_members_options,
  }
  ha_cluster{'keystone-admin':
                node => 'keystone',
                port => 35357,
                cluster_options => ['tcplog','httpchk','tcpka'],
                members_options => $default_members_options,
  }
  ha_cluster{'keystone-public':
                node => 'keystone',
                port => 5000,
                cluster_options => ['tcplog','httpchk','tcpka'],
                members_options => $default_members_options,
  }
  ha_cluster{'cinder-api':
                node => 'cinder',
                port => 8776,
                cluster_options => ['tcplog','httpchk','tcpka'],
                members_options => $default_members_options,
  }
  ha_cluster{'spice':
                node => 'nova',
                port => 6082,
                cluster_options => ['tcplog','tcpka'],
                members_options => $default_members_options,
  }
  ha_cluster{'neutron-api':
                node => 'neutron',
                port => 9696,
                cluster_options => ['tcplog','httpchk','tcpka'],
                members_options => $default_members_options,
  }

  define ha_cluster( $cluster = $title, $node, $port, $cluster_options, $members_options){

          haproxy::listen { "${cluster}_cluster":
                collect_exported => false,
                ipaddress        => $::ipaddress,
                ports            => $port,
                options   => {
                  'option'  => $cluster_options,
                  'balance' => 'source',
                },
          }
          haproxy::balancermember { "${cluster}_${node}0":
                listening_service => "${cluster}_cluster",
                server_names      => "${node}.stack.opensteak.fr",
                ipaddresses       => $opensteak::ha::members_ip["${node}"],
                ports             => $port,
                options           => $members_options,
          }
          haproxy::balancermember { "${cluster}_${node}1":
                listening_service => "${cluster}_cluster",
                server_names      => "${node}2.stack.opensteak.fr",
                ipaddresses       => $opensteak::ha::members_ip["${node}2"],
                ports             => $port,
                options           => $members_options,
          }
  }

}


