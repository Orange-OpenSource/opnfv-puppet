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
  # Recupere le password pour les services
  $password = hiera('mysql::service-password')

  # Recupere les domaines
  $stack_domain = hiera('stack::domain')

  class { '::glance::api':
    verbose                 => hiera('verbose'),
    debug                   => hiera('debug'),
    auth_host               => "keystone.${stack_domain}",
    keystone_password       => hiera('glance::password'),
    database_connection     => "mysql://glance:${password}@mysql.${stack_domain}/glance",
  }

  class { '::glance::backend::file': 
    filesystem_store_datadir => hiera('glance::file-store-dir'),
  }

  class { '::glance::registry':
    verbose                 => hiera('verbose'),
    debug                   => hiera('debug'),
    keystone_password       => hiera('glance::password'),
    database_connection     => "mysql://glance:${password}@mysql.${stack_domain}/glance",
    auth_host               => "keystone.${stack_domain}",
  }

  class { '::glance::notify::rabbitmq': 
    rabbit_password => hiera('rabbitmq::password'),
    rabbit_host     => "rabbitmq.${stack_domain}",
  }
}
