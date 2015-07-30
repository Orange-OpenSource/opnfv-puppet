#
# Copyright (C) 2015 Orange Labs
# 
# This software is distributed under the terms and conditions of the 'Apache-2.0'
# license which can be found in the file 'LICENSE.txt' in this package distribution 
# or at 'http://www.apache.org/licenses/LICENSE-2.0'. 
#
# Authors: Arnaud Morin <arnaud1.morin@orange.com> 
#          David Blaisonneau <david.blaisonneau@orange.com>
#

#
#  The profile to install the needed repo
#
class opensteak::puppet (
    $foreman_fqdn = "foreman.infra.opensteak.fr"
){
    
    package{ 'puppet':
        ensure => installed,
    }
    ->
    file { '/etc/puppet/auth.conf':
        content => template("opensteak/puppet_auth.conf.erb"),
    }
    service { 'puppet':
        ensure => running,
    }
}
