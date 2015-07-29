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
    pip::install { ['foreman']:
        ensure          => present,
        python_version  => '3',
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
    }
    ->
    # Create metadata template folder
    file { "/opt/metadata/templates":
        ensure  => "directory",
        recurse => true,
        source  => "puppet:///modules/opensteak/metadata/templates/",
    }
    ->
    # Create conf
    file { "/opt/metadata/metadata.conf":
        content => template("opensteak/opensteak-metadata.conf.erb"),
        mode    => "0555",
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

    # Manage apache service
    service { "apache2":
        ensure  => running,
    }

    # Set metadata_ip to the network interface
    exec { "/sbin/ip a a $metadata_ip dev $metadata_interface":
        unless => "/sbin/ip a l $metadata_interface | /bin/grep $metadata_ip",
        notify => Service['apache2'],
    }

    # Set configuration in foreman apache conf
    file { "/etc/apache2/sites-enabled/05-foreman.conf":
        content => template("opensteak/05-foreman.conf.erb"),
        notify => Service['apache2'],
    }

    # Enable apache modes (we do not user apache2::enmods to avoid
    # issues with foreman-installer config
    file { '/etc/apache2/mods-enabled/proxy.conf':
        ensure => 'link',
        target => '/etc/apache2/mods-available/proxy.conf',
        notify => Service['apache2'],
    }
    file { '/etc/apache2/mods-enabled/proxy_http.load':
        ensure => 'link',
        target => '/etc/apache2/mods-available/proxy_http.load',
        notify => Service['apache2'],
    }
    file { '/etc/apache2/mods-enabled/proxy.load':
        ensure => 'link',
        target => '/etc/apache2/mods-available/proxy.load',
        notify => Service['apache2'],
    }
}
