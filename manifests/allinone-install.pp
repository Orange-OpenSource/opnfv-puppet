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
#  The profile to install opensteak
#

class opensteak::allinone-install {
    require opensteak::base-network

    file { '/root/install.sh':
        source => "puppet:///modules/opensteak/allinone-install.sh",
    }

    file { '/root/common.yaml':
        content => template("opensteak/allinone-common.yaml.erb"),
    }

    file { '/root/physical-nodes.yaml':
        content => template("opensteak/physical-nodes.yaml.erb"),
    }

    exec { '/root/install.sh':
        require => [
            File['/root/install.sh'],
            File['/root/common.yaml'],
            File['/root/physical-nodes.yaml'],
        ],
    }
}
