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
#  The profile to install the needed repo
#
class opensteak::apt {

  apt::source { 'ubuntu_cloud_openstack_juno':
    location   => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
    release    => 'trusty-updates/juno',
    repos      => 'main',
    key        => 'EC4926EA',
    key_server => 'keyserver.ubuntu.com',
  }
}
