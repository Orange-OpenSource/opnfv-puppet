#
# Copyright (C) 2014 Orange Labs
#
# This software is distributed under the terms and conditions of the 'Apache-2.0'
# license which can be found in the file 'LICENSE.txt' in this package distribution
# or at 'http://www.apache.org/licenses/LICENSE-2.0'.
#
# Authors: David Blaisonneau <david.blaisonneau@orange.com>
#          Arnaud Morin <arnaud1.morin@orange.com>
#
#

#
#  Set the known-hosts file from a list of hosts (comma separated)
#    $known_hosts_file = the known_hosts file,
#    $hosts = comma separated list of servers,
#    $owner = user,
class opensteak::known-hosts (
    $known_hosts_file = '/root/.ssh/known_hosts',
    $hosts = 'server1, server2',
    $owner = 'root',
    ){

    exec { "create $known_hosts_file":
        command => "echo \"$hosts\" | tr ',' \"\\n\"|ssh-keyscan  -H -f - > $known_hosts_file",
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    }
    file { "$known_hosts_file":
        mode => 0600,
        owner => $owner,
        group => $owner,
    }
}
