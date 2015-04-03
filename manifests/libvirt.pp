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
    $default_pool_target = '/var/lib/libvirt/images',
    $sshkey_value = $global_sshkey, # waiting Hammer cli PR 153 - https://github.com/theforeman/hammer-cli-foreman/pull/153
    $sshkey_user = 'foreman@foreman',
    $sshkey_type = 'ssh-rsa',
    $user = 'ubuntu',
){
    #~ Install libvirt
    class { '::libvirt':
        mdns_adv => false
    }
    
    #~ Install and configure policykit for a remote usage of libvirt
    package{ "policykit-1":
        ensure  => present,
    }
    
    $polkit = "[Allow $user libvirt management permissions]
Identity=unix-user:$user
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes"
    file {  '/etc/polkit-1/localauthority/50-local.d/libvirt':
        ensure  => present,
        content => $polkit,
        require => Package["policykit-1"],
    }
    
    #~ Add ssh key to have direct connection
    if ( $sshkey_value ){
        ssh_authorized_key { $sshkey_owner:
            user => $user,
            ensure => present,
            type => $sshkey_type,
            key  => $sshkey_value,
        }
    }
}
