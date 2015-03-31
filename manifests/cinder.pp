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
class opensteak::cinder (
    $debug              = "false",
    $verbose            = "false",
    $region             = "Lannion",
    $mysql_password     = "password",
    $stack_domain       = "stack.opensteak.fr",
    $rabbitmq_password  = "password",
    $cinder_password    = "password",
    $ceph_enabled       = false,
    $libvirt_rbd_secret = "457eb676-33da-42ec-9a8c-9293d545c337",
  ){
  require opensteak::apt

  class { '::cinder':
    database_connection => "mysql://cinder:${mysql_password}@mysql.${stack_domain}/cinder",
    rabbit_host         => "rabbitmq.${stack_domain}",
    rabbit_password     => $rabbitmq_password,
    debug               => $debug,
    verbose             => $verbose,
  }

  class { 'cinder::api':
    keystone_password   => $cinder_password,
    keystone_auth_host  => "keystone.${stack_domain}",
  }

  class { '::cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.filter_scheduler.FilterScheduler',
  }

  class { '::cinder::volume': }

  if $ceph_enabled {
    class { '::cinder::volume::rbd': 
      rbd_pool        => 'vms',
      rbd_user        => 'cinder',
      rbd_secret_uuid => $libvirt_rbd_secret,
    }
  }
}
