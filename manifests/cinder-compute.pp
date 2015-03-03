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
# The profile to install the dns machine
#
class opensteak::cinder-compute {
  require opensteak::apt

  $rbd_secret_uuid = hiera('rbd_secret_uuid')

  # Cinder use ceph client command from ceph-common package
  package { 'ceph-common':
    ensure => installed,
  }
  
  # TODO find a way to push /etc/ceph/ceph.client.cinder.key
  # Maybe at ceph install

  file { '/etc/ceph/secret.xml':
    mode    => '0660',
    owner   => 'root',
    group   => 'root',
    ensure  => present,
    content => template("opensteak/secret.xml.erb"),
  }
  ->
  exec { '/usr/bin/virsh secret-define --file /etc/ceph/secret.xml':
    unless  => "/usr/bin/virsh secret-get-value --secret ${rbd_secret_uuid}",
  }
  ->
  exec { "/usr/bin/virsh secret-set-value --secret ${rbd_secret_uuid} --base64 $(cat /etc/ceph/ceph.client.cinder.key)":
    unless  => "/usr/bin/virsh secret-get-value --secret ${rbd_secret_uuid}",
  }
  
}
