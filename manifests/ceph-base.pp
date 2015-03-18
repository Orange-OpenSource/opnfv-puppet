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
class opensteak::ceph-base {

  $infra_controllers_names = hiera('infra::ceph-controllers')
  $infra_nodes =  hiera('infra::nodes')
  $infra_controllers_ip = inline_template("<%= infra_nodes.select { |keys,_| infra_controllers_names.include? keys }.values.map{|x| x['ip']} %>")
  $storage_network = hiera('storage::network')
  $storage_netmask = hiera('storage::network_mask')
  $infra_network = hiera('infra::network')
  $infra_netmask = hiera('infra::network_mask')

  class { '::ceph::repo': }

  class { '::ceph':
    fsid                => hiera('ceph-conf::fsid'),
    mon_initial_members => join($infra_controllers_names,','),
    mon_host            => join($infra_controllers_ip,','),
    cluster_network     => "${storage_network}/${storage_netmask}",
    public_network      => "${infra_network}/${infra_netmask}",
  }
}


