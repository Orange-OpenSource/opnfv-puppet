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
class opensteak::nova-compute {
  require opensteak::apt

  $password = hiera('mysql::service-password')
  $stack_domain = hiera('stack::domain')
  $rbd_secret_uuid = hiera('rbd_secret_uuid')

  class { '::nova':
    verbose             => hiera('verbose'),
    debug               => hiera('debug'),
    glance_api_servers  => "http://glance.${stack_domain}:9292",
    rabbit_host         => "rabbitmq.${stack_domain}",
    rabbit_password     => hiera('rabbitmq::password'),
  }

  class { '::nova::network::neutron':
    neutron_admin_password => hiera('neutron::password'),
    neutron_region_name    => hiera('region'),
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
    vncserver_proxyclient_address => "nova.${stack_domain}",
    vncproxy_host                 => hiera("horizon::fqdn"),
    vnc_keymap                    => 'fr',
  }

  class { '::nova::compute::rbd':
    libvirt_rbd_user        => 'cinder',
    libvirt_rbd_secret_uuid => "${rbd_secret_uuid}",
    libvirt_images_rbd_pool => 'vms',
    rbd_keyring             => 'client.cinder',
  }

  package { 'sysfsutils':
    ensure => installed,
  }
}
