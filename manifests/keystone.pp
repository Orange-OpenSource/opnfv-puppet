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
class opensteak::keystone (
    $debug              = "false",
    $verbose            = "false",
    $region             = "Lannion",
    $mysql_password     = "password",
    $stack_domain       = "stack.opensteak.fr",
    $rabbitmq_password  = "password",
    $keystone_token     = "password",
    $admin_mail         = "contact@opensteak.fr",
    $admin_password     = "password",
    $admin_tenant       = "admin",
    $glance_password    = "password",
    $neutron_password   = "password",
    $nova_password      = "password",
    $cinder_password    = "password",
  ){
  include pip
  require opensteak::apt

  package { ['libffi-dev','python-dev']:
    ensure  => present,
  }

  pip::install { 'python-openstackclient':
    ensure  => present,
  }

  class { '::keystone':
    verbose                 => $verbose,
    debug                   => $debug,
    admin_token             => $keystone_token,
    database_connection     => "mysql://keystone:${mysql_password}@mysql.${stack_domain}/keystone",
    rabbit_host             => "rabbitmq.${stack_domain}",
    rabbit_password         => $rabbitmq_password,
  }

  class { '::keystone::roles::admin':
    email                   => $admin_mail,
    password                => $admin_password,
    admin_tenant            => $admin_tenant,
  }

  class { '::keystone::endpoint':
    public_url       => "http://keystone.${stack_domain}:5000",
    admin_url        => "http://keystone.${stack_domain}:35357",
    region           => $region,
  }

  class { 'keystone::cron::token_flush': }

  class { '::glance::keystone::auth':
    password         => $glance_password,
    public_address   => "glance.${stack_domain}",
    admin_address    => "glance.${stack_domain}",
    internal_address => "glance.${stack_domain}",
    region           => $region,
  }

  class { '::nova::keystone::auth':
    password         => $nova_password,
    public_address   => "nova.${stack_domain}",
    admin_address    => "nova.${stack_domain}",
    internal_address => "nova.${stack_domain}",
    region           => $region,
  }

  class { '::neutron::keystone::auth':
    password         => $neutron_password,
    public_address   => "neutron.${stack_domain}",
    admin_address    => "neutron.${stack_domain}",
    internal_address => "neutron.${stack_domain}",
    region           => $region,
  }

  class { '::cinder::keystone::auth':
    password         => $cinder_password,
    public_address   => "cinder.${stack_domain}",
    admin_address    => "cinder.${stack_domain}",
    internal_address => "cinder.${stack_domain}",
    region           => $region,
  }
}
