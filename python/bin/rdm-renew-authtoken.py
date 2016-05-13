#!/usr/bin/env python
import argparse

import os
import sys
import time
import datetime
import tempfile

sys.path.append('%s/external' % os.environ['DCCN_PYTHONDIR'])
sys.path.append('%s/lib' % os.environ['DCCN_PYTHONDIR'])
from rdm.IRDM import IRDMRestful, IRDMIcommand, IRDMException
from common.Logger import getLogger

if __name__ == "__main__":

    # command-line argument validators
    def valid_path(s):
        if os.path.isfile(s):
            return s
        else:
            msg = "Invalid filesystem path: %s" % s
            raise argparse.ArgumentTypeError(msg)

    parg = argparse.ArgumentParser(description='renew the client authentication token of accessing the RDM system')

    ## optional arguments
    parg.add_argument('--config',
                      action='store',
                      dest='config',
                      type=valid_path,
                      default='%s/config/rdm-upload-dicom-studies.ini' % os.environ['DCCN_PYTHONDIR'],
                      help='specify the configuration file for connecting the DI-RDM and DICOM PACS servers')

    parg.add_argument('--rdm-imode',
                      action='store',
                      dest='rdm_imode',
                      choices=['icommands', 'restful'],
                      default='icommands',
                      help='specify the iRODS client interface for RDM.  Supported interfaces are "icommands" and "restful"')

    parg.add_argument('--otp',
                       dest='use_otp',
                       action='store_true',
                       default=True,
                       help='indicate to renew with a fresh One-time password')

    args = parg.parse_args()
    logger = getLogger(name=os.path.basename(__file__), lvl=3)


    ## initialize the IRDM interface
    irdm = None
    rdmUserName = None
    if args.rdm_imode in ['icommands']:
        irdm = IRDMIcommand(args.config, lvl=3)
        rdmUserName = irdm.config.get('RDM', 'irodsUserName')
    else:
        irdm = IRDMRestful(args.config, lvl=3)
        rdmUserName = irdm.irods_username

    ## when using OTP, retrieve the fresh one-time password and apply it to the next login attempt
    if args.use_otp:
        ## TODO: need a better way to organise irods rules for RDM client
        rule_fpath = os.path.join(os.environ['IRDM_RULE_PREFIX'],'getUserNextHOTP.r')
        out = irdm.__rdm_exec_rule__(irule_script=rule_fpath, inputs={'userName': rdmUserName})

        if out['ec'] == 0:
            irdm.irods_password = out['otp']
            irdm.config.set('RDM','irodsPassword', value=out['otp'])

    ## remove the file in which the authentication token is stored
    if irdm.config.get('RDM', 'irodsAuthCached'):
        try:
            os.unlink(irdm.config.get('RDM', 'irodsAuthFileName'))
        except Exception, e:
            pass

    ## perform a new login to acquire the new authentication token
    irdm.login()
