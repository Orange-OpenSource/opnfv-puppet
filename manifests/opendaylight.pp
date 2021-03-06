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
#  The profile to install horizon
#
class opensteak::opendaylight {
    
    class { '::opendaylight':
        install_method => 'tarball',
        extra_features => ['odl-base-all','odl-aaa-authn','odl-restconf',
            'odl-nsf-all','odl-adsal-northbound','odl-mdsal-apidocs',
            'odl-ovsdb-plugin', 'odl-ovsdb-openstack']
    }

}
