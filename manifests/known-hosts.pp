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
#  Set the known-hosts file
#
class opensteak::known-hosts (
    $known_host_file,
    $hosts,
    ){

    exec { "create $known_host_file":
        command => "echo \"$hosts\" | tr ',' \"\\n\"|ssh-keyscan  -H -f - > $known_host_file",
        refreshonly => true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    }
    file { "$known_host_files":
        mode => 0600,
    }
}
