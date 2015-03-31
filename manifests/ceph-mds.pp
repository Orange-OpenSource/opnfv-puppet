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
class opensteak::ceph-mds (
    $mds_key = "AQC0g8tUGCzgAxAAbiynJ/yvu463DcMESVVbXw==",
  ){
  require opensteak::ceph-base

  class { '::ceph::mds':  }

  if ! defined(Ceph::Key["mds.${::hostname}"]) {
    ceph::key { "mds.${::hostname}":
      inject         => true,
      inject_as_id   => 'mon.',
      inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
      secret  => $mds_key,
      cap_mon => 'allow profile mds',
      cap_osd => 'allow rws',
      cap_mds => 'allow',
    }
  }
}


