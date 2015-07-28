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
        host = foreman.hosts[hostname]
        # Get the hostgroup
        if host['hostgroup_id']:
            hg = foreman.hostgroups[host['hostgroup_id']]
        else:
            hg = None
        # get the domain
        domain = foreman.domains[host['domain_id']]
        ret = host.getUserData(hostgroup=hg,
                               domain=domain['name'],
                               tplFolder='{}/templates/'.format(confRoot))
        p.status(bool(ret), "VM {0}: sent user data".format(hostname))
        self.write(ret)


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
        p.status(bool(ret), "VM {0}: sent meta data '{1}' with value '{2}'"
                            .format(hostname, meta, ret))
        self.write(ret)


class StatusPrinter:
    """ Just a nice message printer """
    OKGREEN = '\033[92m'
    FAIL = '\033[91m'

    TABSIZE = 4

    def status(self, res, msg, failed="", eol="\n", quit=True, indent=0):
        """ Function status
        Print status message
        - OK/KO if the result is a boolean
        - Else the result text

        @param res: The status to show
        @param msg: The message to show
        @param failed: The error message if failed
        @param eol: End of line
        @param quit: Exit the system in case of failure
        @param indent: Tab size at the beginning of the line
        @return RETURN: None
        """
        ind = ' ' * indent * self.TABSIZE
        if res is True:
            msg = '{} [{}OK{}] {}'.format(ind, self.OKGREEN, self.ENDC, msg)
        else:
            msg = '{} [{}KO{}] {}'.format(ind, self.FAIL, self.ENDC, msg)
            if failed:
                msg += '\n > {}'.format(failed)
        msg = msg.ljust(140) + eol
        sys.stdout.write(msg)
        if res is False and quit is True:
            sys.exit(0)


def getIP(request):
    if 'X-Forwarded-For' in request.headers.keys():
        return request.headers['X-Forwarded-For']
    else:
        return request.remote_ip


def getNameFromSourceIP(ip):
    return socket.gethostbyaddr(ip)[0]


application = tornado.web.Application([
    (r'.*/user-data', UserDataHandler),
    (r'.*/meta-data/(.*)', MetaDataHandler),
])

if __name__ == "__main__":
    p = StatusPrinter()

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
                        default=foremanOptions['username'])
    parser.add_argument('-p', '--password',
                        help='Password to connect to foreman (default is '
                              '{0}).'.format(config['foreman']['password']),
                        default=foremanOptions['password'])
    parser.add_argument('-i', '--ip',
                        help='IP address of foreman (default is '
                              '{0}).'.format(config['foreman']['ip']),
                        default=foremanOptions['ip'])
    args.update(vars(parser.parse_args()))

    foreman = Foreman(login=args["admin"],
                      password=args["password"],
                      ip=args["ip"])

    print("Run server on port {}".format(config['server']['port']))
    application.listen(config['server']['port'])
    tornado.ioloop.IOLoop.instance().start()
