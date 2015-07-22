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
# The dhcp class for foreman installer
#

include stdlib

#~ Variable structure example:
#~      dnsdomain => ['infra.opensteak.fr','0.168.192.in-addr.arpa','1.168.192.in-addr.arpa','2.168.192.in-addr.arpa']
#~      interfaces => ['eth0','eth1','eth2']
#~      pools (YAML vars from foreman):
#~        pools:
#~          adm.infra.opensteak.fr:
#~             network: 192.168.1.0
#~             netmask: 255.255.255.0
#~             range: 192.168.1.50 192.168.1.99
#~             gateway: 192.168.1.1

class opensteak::dhcp (
    $dnsdomain = [$domain],
    $pools = { "domain"=> { "network"=> "192.168.1.0",
                            "netmask"=> "255.255.255.0",
                            "range"=> "192.168.1.50 192.168.1.99",
                            "gateway"=> "192.168.1.1" }},
    $nameservers = [$ipaddress],
    $interfaces = $interfaces,
    $pxeserver = $ipaddress,
    $pxefilename  = 'pxelinux.0',
){
    class { '::dhcp':
        dnsdomain    => $dnsdomain,
        nameservers  => $nameservers,
        interfaces   => $interfaces,
        dnsupdatekey => "/etc/bind/rndc.key",
        pxeserver    => $pxeserver,
        pxefilename  => $pxefilename,
        option_static_route => true,
    }
    $poolslist = keys($pools['pools'])
    define mypool($poolname = $title){
        $pooldef = $opensteak::dhcp::pools['pools'][$poolname]
        if $pooldef['gateway']{
                $static_routes = [ { 'mask' => '32', 'network' => '169.254.169.254', 'gateway' => $ipaddress } ]
        }else{
                $static_routes = undef
        }
        dhcp::pool{ "pool_${poolname}":
            network => $pooldef['network'],
            mask    => $pooldef['netmask'],
            range   => $pooldef['range'],
            gateway => $pooldef['gateway'],
            domain_name => "${poolname}",
            static_routes => $static_routes,
        }
    }
    mypool{$poolslist:}
}
