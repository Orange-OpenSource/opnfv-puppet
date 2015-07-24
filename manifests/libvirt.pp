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
    $ovs_config = ["br-adm:em3:dhcp","br-vm:em5:dhcp","br-ex:em2:none"],
    $cloud_img_url = "http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img",
    $pool_folder = '/var/lib/libvirt/images',
){
    #~ Install libvirt
    class { '::libvirt':
        mdns_adv => false
    }

    #~ Configure network
    ovs-network { $ovs_config: }
    define ovs-network (){
        $value      = split($name,':')
        $bridge     = $value[0]
        $interface  = $value[1]
        libvirt::network { $bridge:
            ensure             => enabled,
            autostart          => true,
            forward_mode       => 'bridge',
            bridge             => $bridge,
            virtualport_type   => 'openvswitch',
            portgroup_name     => $interface,
        }
    }

    #~  Configure default pool
    libvirt_pool { 'default' :
        ensure   => present,
        type     => 'dir',
        active => true,
        autostart => true,
        target   => $pool_folder,
    }

    #~ Get the ubuntu cloud image
    $cloud_img_name_arr = split($cloud_img_url, '/')
    $cloud_img_name = $cloud_img_name_arr[-1]
    exec{'retrieve_cloud_image':
        command => "/usr/bin/wget -q $cloud_img_url -O ${pool_folder}/${cloud_img_name}",
        creates => "${pool_folder}/${cloud_img_name}",
    }
    ->
    exec{'refresh_default_pool':
        command => "/usr/bin/virsh pool-refresh default",
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
        ssh_authorized_key { $sshkey_user:
            user => $user,
            ensure => present,
            type => $sshkey_type,
            key  => $sshkey_value,
        }
    }
}
