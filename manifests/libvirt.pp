
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
# The libvirt class for foreman installer
#

class opensteak::libvirt (
    $sshkey,
    $sshkey_owner = 'foreman@foreman',
    $ceph = false,
){
    class { '::libvirt':
        mdns_adv => false
    }

    libvirt_pool { 'default' :
        ensure   => present,
        type     => 'dir',
        target   => '/var/lib/libvirt/images',
    }
    sshkey { $sshkey_owner:
        ensure => present,
        type => "rsa",
        key  => $sshkey,
    }
}
