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
#  The profile to install (nova controller part)
#
class opensteak::nova-compute (
    $debug              = "false",
    $verbose            = "false",
    $region             = "Lannion",
    $mysql_password     = "password",
    $stack_domain       = "stack.opensteak.fr",
    $rabbitmq_password  = "password",
    $neutron_password   = "password",
    $ceph_enabled       = false,
    $libvirt_rbd_secret = "457eb676-33da-42ec-9a8c-9293d545c337",
    $mtu                = "9160",
  ){
  require opensteak::apt

  class { '::nova':
    verbose             => $verbose,
    debug               => $debug,
    glance_api_servers  => "http://glance.${stack_domain}:9292",
    rabbit_host         => "rabbitmq.${stack_domain}",
    rabbit_password     => $rabbitmq_password,
  }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_password,
    neutron_region_name    => $region,
    neutron_admin_auth_url => "http://keystone.${stack_domain}:35357/v2.0",
    neutron_url            => "http://neutron.${stack_domain}:9696",
  }

  # TODO: add live_migration_flag
  class { '::nova::compute::libvirt': 
    vncserver_listen  => '0.0.0.0',
    migration_support => true,
  }

  class { '::nova::compute':
    enabled                       => true,
    vncserver_proxyclient_address => $ipaddress,
    vncproxy_host                 => "nova.${stack_domain}",
    vnc_keymap                    => 'fr',
    network_device_mtu            => $mtu,
  }

  if $ceph_enabled {
    class { '::nova::compute::rbd':
      libvirt_rbd_user        => 'cinder',
      libvirt_rbd_secret_uuid => $libvirt_rbd_secret,
      libvirt_images_rbd_pool => 'vms',
      rbd_keyring             => 'client.cinder',
    }
  }

  package { 'sysfsutils':
    ensure => installed,
  }
}
