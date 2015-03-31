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
class opensteak::ceph-mon (
    $mon_key    = "AQAJcMpUAAAAABAAXUZk1mOusq5pyOmnhBfElg==",
    $admin_key  = "AQBvW8tUMKg7FBAABuiYm434KAYTilIaESJaAQ==",
    $osd_key    = "AQBvW8tUyOFPKRAA9OC5DmhyLLmHuE5f+qKbgQ==",
    $mds_key    = "AQBwW8tU4LdvAhAA2VO8W9/M0TQFf4xl14tUBA==",
    $cinder_key = "AQAPns9UUBRDEhAAX3UhTWUw6OXTjw/TPv6wdw==",
    $glance_key = "AQB6ns9UWJCEBhAAz1632+o+zxgMLGrXlp3rHQ==",
  ){
  require opensteak::ceph-base

  ceph::mon { $::hostname:
    key => $mon_key,
  }

  Ceph::Key {
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
  }

  ceph::key { 'client.admin':
    secret  => $admin_key,
    cap_mon => 'allow *',
    cap_osd => 'allow *',
    cap_mds => 'allow',
  }

  ceph::key { 'client.bootstrap-osd':
    secret  => $osd_key,
    cap_mon => 'allow profile bootstrap-osd',
  }

  ceph::key { 'client.bootstrap-mds':
    secret  => $mds_key,
    cap_mon => 'allow profile bootstrap-mds',
  }

  ceph::key { 'client.cinder':
    secret          => $cinder_key,
    cap_mon         => 'allow r',
    cap_osd         => 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images',
  }

  ceph::key { 'client.glance':
    secret          => $glance_key,
    cap_mon         => 'allow r',
    cap_osd         => 'allow class-read object_prefix rbd_children, allow rwx pool=images',
  }
}


