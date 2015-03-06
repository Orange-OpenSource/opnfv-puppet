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
# The profile to install ceph MDS
#
class opensteak::ceph-mds {
  require opensteak::ceph-base

  class { '::ceph::mds':  }

  if ! defined(Ceph::Key["mds.${::hostname}"]) {
    ceph::key { "mds.${::hostname}":
      inject         => true,
      inject_as_id   => "mds.${::hostname}",
      inject_keyring => "/var/lib/ceph/mds/ceph-${::hostname}/keyring",
      secret  => hiera('ceph-conf::mds-key'),
      cap_mon => 'allow profile mds',
      cap_osd => 'allow rws',
      cap_mds => 'allow',
    }
  }
}


