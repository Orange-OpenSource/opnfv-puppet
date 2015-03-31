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
# The profile to install ceph OSDs
#
class opensteak::ceph-osd (
    $secret = "AQBvW8tUyOFPKRAA9OC5DmhyLLmHuE5f+qKbgQ==",
  ){
  require opensteak::ceph-base

  ceph::osd { $disk: }

  if ! defined(Ceph::Key['client.bootstrap-osd']) {
    ceph::key { 'client.bootstrap-osd':
      keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
      secret       => $secret,
    }
  }
}


