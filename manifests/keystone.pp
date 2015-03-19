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
#  The profile to install keystone base
#
class opensteak::keystone-base {
  include pip
  require opensteak::apt

  $password = hiera('mysql::service-password')
  $stack_domain = hiera('stack::domain')

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
  }

  class { '::keystone::roles::admin':
    email                   => hiera('admin::mail'),
    password                => hiera('admin::password'),
    admin_tenant            => hiera('admin::tenant'),
  }

#  class { '::keystone::endpoint':
#    public_url       => "http://keystone.${stack_domain}:5000",
#    admin_url        => "http://keystone.${stack_domain}:35357",
#    region           => hiera('region'),
#  }

  keystone::resource::service_identity { 'keystone':
    configure_user      => false,
    configure_user_role => false,
    configure_service   => false,
    service_type        => 'identity',
    service_description => 'OpenStack Identity Service',
    public_url          => "http://keystone.${stack_domain}:5000",
    admin_url           => "http://keystone.${stack_domain}:35357",
    internal_url        => "http://keystone.${stack_domain}:5000",
    region              => hiera('region'),
  }

  class { 'keystone::cron::token_flush': }
}

#
#  The profile to install keystone auth
#
class opensteak::keystone {
  require opensteak::keystone

  $password = hiera('mysql::service-password')
  $stack_domain = hiera('stack::domain')

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

  class { '::cinder::keystone::auth':
    password         => hiera('cinder::password'),
    public_address   => "cinder.${stack_domain}",
    admin_address    => "cinder.${stack_domain}",
    internal_address => "cinder.${stack_domain}",
    region           => hiera('region'),
  }
}
