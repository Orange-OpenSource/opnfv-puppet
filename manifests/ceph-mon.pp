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
# The profile to install ceph monitors
#
class opensteak::ceph-mon {
  require opensteak::ceph-base

  ceph::mon { $::hostname:
    key => hiera('ceph-conf::mon-key'),
  }

  Ceph::Key {
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
  }

  ceph::key { 'client.admin':
    secret  => hiera('ceph-conf::client-admin-key'),
    cap_mon => 'allow *',
    cap_osd => 'allow *',
    cap_mds => 'allow',
  }

  ceph::key { 'client.bootstrap-osd':
    secret  => hiera('ceph-conf::client-bootstrap-osd-key'),
    cap_mon => 'allow profile bootstrap-osd',
  }

  ceph::key { 'client.bootstrap-mds':
    secret  => hiera('ceph-conf::client-bootstrap-mds-key'),
    cap_mon => 'allow profile bootstrap-mds',
  }

  ceph::key { 'client.cinder':
    secret          => hiera('ceph-conf::client-cinder-key'),
    cap_mon         => 'allow r',
    cap_osd         => 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images',
  }

  ceph::key { 'client.cinder-backup':
    secret          => hiera('ceph-conf::client-cinder-backup-key'),
    cap_mon         => 'allow r',
    cap_osd         => 'allow class-read object_prefix rbd_children, allow rwx pool=backups',
  }

  ceph::key { 'client.glance':
    secret          => hiera('ceph-conf::client-glance-key'),
    cap_mon         => 'allow r',
    cap_osd         => 'allow class-read object_prefix rbd_children, allow rwx pool=images',
  }
}


