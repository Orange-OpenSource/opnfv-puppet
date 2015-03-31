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
# The profile to install ceph
#
class opensteak::ceph-base (
    $infra_controllers_names    = ["controller1"],
    $infra_nodes                = { controller1 => 
                                    {   ip => "192.168.1.42" ,
                                        bridge_uplinks => ["br-ex:em2","br-vm:em5"],
                                    }
                                  },
    $storage_network            = "192.168.0.0",
    $storage_netmask            = "24",
    $infra_network              = "192.168.1.0",
    $infra_netmask              = "24",
    $fsid                       = "77a16382-8b32-476d-89b8-5ac5381209b7",
  ){
  $infra_controllers_ip = inline_template("<%= infra_nodes.select { |keys,_| infra_controllers_names.include? keys }.values.map{|x| x['ip']}.join(',') %>")
  
  class { '::ceph::repo': }

  class { '::ceph':
    fsid                => $fsid,
    mon_initial_members => join($infra_controllers_names,','),
    mon_host            => $infra_controllers_ip, # already joined by ruby
    cluster_network     => "${storage_network}/${storage_netmask}",
    public_network      => "${infra_network}/${infra_netmask}",
  }
}


