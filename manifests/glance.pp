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
#  The profile to install glance
#
class opensteak::glance {
  require opensteak::apt

  $password = hiera('mysql::service-password')
  $stack_domain = hiera('stack::domain')
  $ceph_enabled = hiera('ceph::enabled')

  if str2bool("$ceph_enabled" ){
    $known_stores = ['glance.store.rbd.Store']
  }
  else{
    $known_stores = ['glance.store.filesystem.Store']
  }

  class { '::glance::api':
    verbose                 => hiera('verbose'),
    debug                   => hiera('debug'),
    auth_host               => "keystone.${stack_domain}",
    auth_uri                => "http://keystone.${stack_domain}:5000/v2.0",
    keystone_password       => hiera('glance::password'),
    database_connection     => "mysql://glance:${password}@mysql.${stack_domain}/glance",
    pipeline                => "keystone",
    show_image_direct_url   => true,
    known_stores            => $known_stores,
  }

  # Temp hack while identity_uri can't be set by glance puppet module
  glance_api_config { 'keystone_authtoken/identity_uri': value => "http://keystone.${stack_domain}:35357"; }

  if str2bool("$ceph_enabled" ){
    class { '::glance::backend::rbd': 
    rbd_store_user  => 'glance',
    rbd_store_pool  => 'images',
    }
  }
  else{
    class { '::glance::backend::file': }
  }

  class { '::glance::registry':
    verbose                 => hiera('verbose'),
    debug                   => hiera('debug'),
    keystone_password       => hiera('glance::password'),
    database_connection     => "mysql://glance:${password}@mysql.${stack_domain}/glance",
    auth_host               => "keystone.${stack_domain}",
  }

  # Temp hack while identity_uri can't be set by glance puppet module
  glance_registry_config { 'keystone_authtoken/identity_uri': value => "http://keystone.${stack_domain}:35357"; }

  class { '::glance::notify::rabbitmq': 
    rabbit_password => hiera('rabbitmq::password'),
    rabbit_host     => "rabbitmq.${stack_domain}",
  }
}
