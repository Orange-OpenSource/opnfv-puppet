#
# Copyright (C) 2015 Orange Labs
#
# This software is distributed under the terms and conditions of the 'Apache-2.0'
# license which can be found in the file 'LICENSE.txt' in this package distribution
# or at 'http://www.apache.org/licenses/LICENSE-2.0'.
#
# Authors: Arnaud Morin <arnaud1.morin@orange.com>
#          David Blaisonneau <david.blaisonneau@orange.com>
#

#
#  The profile to install the metadata server
#
class opensteak::metadata (
    $template_folder = '/opt/metadata/templates',
    $foreman_fqdn = 'foreman.infra.opensteak.fr',
    $foreman_admin = 'admin',
    $foreman_password = 'password',
    $foreman_ip = '127.0.0.1',
    $metadata_ip = '169.254.169.254/32',
    $metadata_interface = 'eth0',
    $metadata_port = 8888,
    ){
    include pip

    # Install prerequisities
    package { 'python3-tornado':
        ensure => installed,
    }
    ->
    pip::install { ['beautifulsoup4', 'PyYAML', 'requests', 'requests-futures']:
        ensure          => present,
        python_version  => '3.4',
    }
    ->
    # Create binary
    file { "/usr/local/bin/opensteak-metadata-server.py":
        source  => "puppet:///modules/opensteak/opensteak-metadata-server.py",
        mode    => "0755",
    }
    ->
    # Create metadata folder
    file { "/opt/metadata":
        ensure  => "directory",
        recurse => True,
        source  => "puppet:///modules/opensteak/metadata/",
    }
    ->
    # Create conf
    file { "/opt/metadata/opensteak-metadata.conf":
        content => template("opensteak/opensteak-metadata.conf.py"),
        mode    => "0755",
    }
    ->
    # Create init
    file { "/etc/init/metadata.conf":
        ensure  => present,
        source  => "puppet:///modules/opensteak/metadata_init",
    }
    ->
    # Start Service
    service { "metadata":
        ensure  => running,
        require => Package['python3-tornado'],
    }

    # Set metadata_ip to the network interface
    exec { "/sbin/ip a a $metadata_ip dev $metadata_interface":
        unless => "/sbin/ip a l $metadata_interface | /bin/grep $metadata_ip",
    }

    # Set configuration in foreman apache conf
    file { "/etc/apache2/sites-enabled/05-foreman.conf":
        content => template("opensteak/05-foreman.conf.erb"),
    }

    #a2enmod proxy_http
    apache::mod { 'proxy_http': }
}
