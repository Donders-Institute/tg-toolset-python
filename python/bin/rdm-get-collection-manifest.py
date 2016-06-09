#!/usr/bin/env python
import argparse

import os
import sys

sys.path.append('%s/external' % os.environ['DCCN_PYTHONDIR'])
sys.path.append('%s/lib' % os.environ['DCCN_PYTHONDIR'])
from rdm.IRDM import IRDMIcommand
from common.Logger import getLogger

if __name__ == "__main__":

    # command-line argument validators
    def valid_path(s):
        if os.path.isfile(s):
            return s
        else:
            msg = "Invalid filesystem path: %s" % s
            raise argparse.ArgumentTypeError(msg)

    parg = argparse.ArgumentParser(description='get manifest of data objects within a collection')

    ## positional arguments
    parg.add_argument('coll',
                      metavar = 'collection',
                      nargs   = 1,
                      help    = 'iRODS namespace of collection')

    ## optional arguments
    parg.add_argument('--config',
                      action='store',
                      dest='config',
                      type=valid_path,
                      default='%s/config/config.ini' % os.environ['DCCN_PYTHONDIR'],
                      help='specify the configuration file for connecting the DI-RDM and DICOM PACS servers')

    parg.add_argument('--rdm-imode',
                      action='store',
                      dest='rdm_imode',
                      choices=['icommands', 'restful'],
                      default='restful',
                      help='specify the iRODS client interface for RDM.  Supported interfaces are "icommands" and "restful"')

    parg.add_argument('-u', '--username',
                       dest='username',
                       action='store',
                       default='',
                       help='username of the RDM data-access account')

    parg.add_argument('-p', '--password',
                      dest='password',
                      action='store',
                      default='',
                      help='OTP of the RDM data-access account')

    args = parg.parse_args()
    logger = getLogger(name=os.path.basename(__file__), lvl=3)

    ## initialize the IRDM interface
    irdm = None
    rdmUserName = None
    if args.rdm_imode in ['icommands']:
        irdm = IRDMIcommand(args.config, lvl=3)

        if args.username:
            irdm.config.set('RDM', 'irodsUserName', args.username)

        if args.password:
            irdm.config.set('RDM', 'irodsPassword', args.password)

        ## perform another login attempt with provided username/password
        irdm.login()
    else:
        ## TODO: is it logical to renew the authtoken for restful or other HTTP-based interfaces?
        irdm = IRDMRestful(args.config, lvl=3)

        if args.username:
            irdm.irods_username = args.username

        if args.password:
            irdm.irods_password = args.password

    ## when using OTP, retrieve the fresh one-time password and apply it to the next login attempt
    rule_fpath = os.path.join(os.environ['IRDM_RULE_PREFIX'],'getCollectionManifest.r')
    out = irdm.__rdm_exec_rule__(irule_script=rule_fpath, inputs={'collName': args.coll[0]})

    for k,v in out.iteritems():
        print('%s %s %s' % (k, v['size'], v['checksum']))
