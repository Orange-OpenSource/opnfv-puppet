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
#  The profile to install mysql
#
class opensteak::mysql {


  class { '::mysql::server':
    root_password                   => hiera("mysql::root-password"),
    override_options                => {
      'mysqld'                      => {
        'bind-address'              => '0.0.0.0' ,
        'default-storage-engine'    => 'innodb',
        'collation-server'          => 'utf8_general_ci',
        'init-connect'              => "'SET NAMES utf8'",
        'character-set-server'      => 'utf8'
      } 
    }
  }

  class { '::mysql::bindings':
    python_enable => true,
  }

  class { '::mysql::server::account_security':
  }

  # Keystone
  class { '::keystone::db::mysql':
    password      => hiera('mysql::service-password'),
    allowed_hosts => '%',
  }

  # Glance
  class { '::glance::db::mysql':
    password      => hiera('mysql::service-password'),
    allowed_hosts => '%',
  }

  # Nova
  class { '::nova::db::mysql':
    password      => hiera('mysql::service-password'),
    allowed_hosts => '%',
  }

  # Neutron
  class { '::neutron::db::mysql':
    password      => hiera('mysql::service-password'),
    allowed_hosts => '%',
  }
}
