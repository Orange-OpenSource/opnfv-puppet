#!/usr/bin/python3
# -*- coding: utf-8 -*-
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Authors:
# @author: David Blaisonneau <david.blaisonneau@orange.com>
# @author: Arnaud Morin <arnaud1.morin@orange.com>

import tornado.ioloop
import tornado.web
import socket
import sys
import argparse
import configparser
from foreman import Foreman


confRoot = '/opt/metadata'
confFile = '{}/metadata.conf'.format(confRoot)


class UserDataHandler(tornado.web.RequestHandler):
    """
    User Data handler
    """
    def get(self):
        """ Function get
        Return UserData script from the foreman API

        @return RETURN: user-data script
        """
        hostname = getNameFromSourceIP(getIP(self.request))
        # If the machine is declared in foreman, handle the userdata
        if hostname is not None:
            host = foreman.hosts[hostname]
            # Get the hostgroup
            if host['hostgroup_id']:
                hg = foreman.hostgroups[host['hostgroup_id']]
            else:
                hg = None
            # get the domain
            domain = foreman.domains[host['domain_id']]
            ret = host.getUserData(hostgroup=hg,
                                   domain=domain,
                                   tplFolder='{}/templates/'
                                   .format(confRoot))
            log(bool(ret), "VM {0}: sent user data".format(hostname))
            self.write(ret)
        else:
            log(False, "No VM with IP '{0}' found in foreman. Trying a reload..."
                .format(getIP(self.request)))
            # Reload foreman.hosts
            foreman.hosts.reload()

class MetaDataHandler(tornado.web.RequestHandler):
    """
    Meta Data handler
    """
    def get(self, meta):
        """ Function get
        Return meta data parameters from the foreman API

        @return RETURN: meta data parameters
        """
        hostname = getNameFromSourceIP(getIP(self.request))
        # If the machine is declared in foreman, handle the userdata
        if hostname is not None:
            host = foreman.hosts[hostname]
            
            available_meta = {
                'name': host['name'],
                'instance-id': host['name'],
                'hostname': host['name'],
                'local-hostname': host['name'],
                }
            if meta in available_meta.keys():
                ret = available_meta[meta]
            elif meta == '':
                ret = "\n".join(available_meta)
            else:
                raise tornado.web.HTTPError(status_code=404,
                                            log_message='No such metadata')
            log(bool(ret),
                "VM {0}: sent meta data '{1}' with value '{2}'"
                .format(hostname, meta, ret))
            self.write(ret)
        else:
            log(False, "No VM with IP '{0}' found in foreman. Trying a reload..."
                .format(getIP(self.request)))
            # Reload foreman.hosts
            foreman.hosts.reload()

def log(res, msg):
        """ Function log
        Print status message
        - OK/KO if the result is a boolean

        @param res: The status to show
        @param msg: The message to show
        @return RETURN: None
        """
        if res is True:
            msg = '[OK] {}'.format(msg)
        else:
            msg = '[KO] {}'.format(msg)
        print(msg)


def getIP(request):
    if 'X-Forwarded-For' in request.headers.keys():
        return request.headers['X-Forwarded-For']
    else:
        return request.remote_ip


def getNameFromSourceIP(ip):
    # Old way to find the IP was to perform a reverse DNS lookup
    # this is working when the machine do DHCP request with its real 
    # hostname.
    # Unfortunately, most of the time, ubuntu cloud machines use the
    # default 'ubuntu' hostname...
    #return socket.gethostbyaddr(ip)[0]

    # New way is to try to find source IP in foreman.hosts hash
    for name, values in foreman.hosts.items():
        if values['ip'] == ip:
            return name

    # Being here suppose that we did not find any host in foreman
    # with this IP
    return None


application = tornado.web.Application([
    (r'.*/user-data', UserDataHandler),
    (r'.*/meta-data/(.*)', MetaDataHandler),
])

if __name__ == "__main__":
    # Read the config file
    config = configparser.ConfigParser()
    config.read(confFile)

    # Update args with values from CLI
    args = {}
    parser = argparse.ArgumentParser(description='This script will run a '
                                                 'metadata server connected '
                                                 'to a foreman server.',
                                     usage='%(prog)s [options]')
    parser.add_argument('-a', '--admin',
                        help='Username to connect to foreman (default is '
                              '{0}).'.format(config['foreman']['username']),
                        default=config['foreman']['username'])
    parser.add_argument('-p', '--password',
                        help='Password to connect to foreman (default is '
                              '{0}).'.format(config['foreman']['password']),
                        default=config['foreman']['password'])
    parser.add_argument('-i', '--ip',
                        help='IP address of foreman (default is '
                              '{0}).'.format(config['foreman']['ip']),
                        default=config['foreman']['ip'])
    args.update(vars(parser.parse_args()))

    foreman = Foreman(login=args["admin"],
                      password=args["password"],
                      ip=args["ip"])

    print("Run server on port {}".format(config['server']['port']))
    application.listen(config['server']['port'])
    tornado.ioloop.IOLoop.instance().start()
