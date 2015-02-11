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
class opensteak::key {
  $tenant = hiera('admin::tenant')
  $username = 'admin'
  $password = hiera('admin::password')
  $domain = hiera('domain')

  file { '/root/os-creds-admin':
    mode    => '0770',
    ensure  => present,
    content => "#!/bin/bash
export OS_TENANT_NAME=$tenant
export OS_USERNAME=$username
export OS_PASSWORD=$password
export OS_AUTH_URL=http://keystone.$domain:35357/v2.0"
  }


}
