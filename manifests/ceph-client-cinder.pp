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
# The profile to install ceph cinder client
#
class opensteak::ceph-client-cinder (
    $secret = "AQAPns9UUBRDEhAAX3UhTWUw6OXTjw/TPv6wdw==",
  ){
  require opensteak::ceph-base

  if ! defined(Ceph::Key['client.cinder']) {
    ceph::key { 'client.cinder':
      secret       => $secret,
    }
  }

  # Ceph conf needed by Nova
  ceph_config {
    'client.cinder/key': value => $secret;
  }
}
