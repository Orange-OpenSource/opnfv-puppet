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
class opensteak::cinder {
  require opensteak::apt

  $domain = hiera('domain')
  $stack_domain = hiera('stack::domain')
  $password = hiera('mysql::service-password')

  class { '::cinder':
    database_connection => "mysql://cinder:${password}@$mysql.${stack_domain}/cinder",
    rabbit_host         => "rabbitmq.${stack_domain}",
    rabbit_password     => hiera('rabbitmq::password'),
    debug               => hiera('debug'),
    verbose             => hiera('verbose'),
  }

  class { '::cinder::volume': }

  class { 'cinder::api':
    keystone_password   => hiera('cinder::password'),
    keystone_auth_host  => "keystone.${stack_domain}",
  }

  class { '::cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.filter_scheduler.FilterScheduler',
  }

  cinder::backend::rbd {'rbd-vms':
    rbd_pool => 'vms',
    rbd_user => 'vms',
  }
}
