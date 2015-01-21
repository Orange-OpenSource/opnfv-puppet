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
#  The profile to install keystone
#
class opensteak::keystone {
  include pip
  
  $password = hiera('mysql::service-password')
  $domain = hiera('domain')
  $stack_domain = hiera('stack::domain')
  
  # Probleme: c'est dans la machine mysql qu'on créer la BDD
  # le script keystone-manage y est appelé mais n'existe pas
  # Decommenter au besoin pour l'appeler
  # Il est normalement appeler à l'install du packet keystone
  # ou quand on modifie le parametre database_connection
  #class { '::keystone::db::sync': }

  package { ['libffi-dev','python-dev']:
    ensure  => present,
  }
  
  pip::install { 'python-openstackclient':
    ensure  => present,
  }

  class { '::keystone':
    verbose                 => hiera('verbose'),
    debug                   => hiera('debug'),
    admin_token             => hiera('keystone::admin-token'),
    database_connection     => "mysql://keystone:${password}@mysql.${stack_domain}/keystone",
    rabbit_host             => "rabbitmq.${stack_domain}",
    rabbit_password         => hiera('rabbitmq::password'),
#    paste_config            => "/etc/keystone/keystone-paste.ini",
#    token_driver            => "keystone.token.backends.sql.Token",
  }

  class { '::keystone::roles::admin':
    email        => hiera('admin::mail'),
    password     => hiera('admin::password'),
    admin_tenant => hiera('admin::tenant'),
  }

  class { '::keystone::endpoint':
    public_url       => "http://keystone.${stack_domain}:5000",
    admin_url        => "http://keystone.${stack_domain}:35357",
    region           => hiera('region'),
  }

  class { '::glance::keystone::auth':
    password         => hiera('glance::password'),
    public_address   => "glance.${stack_domain}",
    admin_address    => "glance.${stack_domain}",
    internal_address => "glance.${stack_domain}",
    region           => hiera('region'),
  }

  class { '::nova::keystone::auth':
    password         => hiera('nova::password'),
    public_address   => "nova.${stack_domain}",
    admin_address    => "nova.${stack_domain}",
    internal_address => "nova.${stack_domain}",
    region           => hiera('region'),
  }

  class { '::neutron::keystone::auth':
    password         => hiera('neutron::password'),
    public_address   => "neutron.${stack_domain}",
    admin_address    => "neutron.${stack_domain}",
    internal_address => "neutron.${stack_domain}",
    region           => hiera('region'),
  }

#  class { '::cinder::keystone::auth':
#    password         => hiera('cinder::password'),
#    public_address   => "cinder.${stack_domain}",
#    admin_address    => "cinder.${stack_domain}",
#    internal_address => "cinder.${stack_domain}",
#    region           => hiera('region'),
#  }

 
}
