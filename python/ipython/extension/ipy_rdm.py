#!/usr/bin/env ipython
import os 
import sys
import json
import argparse
from datetime import datetime, timedelta
sys.path.append('%s/external' % os.environ['DCCN_PYTHONDIR'])
sys.path.append('%s/lib' % os.environ['DCCN_PYTHONDIR'])
from rdm.IRDM import IRDMRestful, IRDMIcommand
from common.Utils import makeTabular

irdm = IRDMRestful(config='%s/config/config.ini' % os.environ['DCCN_PYTHONDIR'], lvl=0)

def load_ipython_extension(ipython):
    ipython.register_magic_function(rdm_list, 'line', magic_name='rdm_list')
    ipython.register_magic_function(rdm_account, 'line', magic_name='rdm_account')
    ipython.register_magic_function(rdm_get_user_profile, 'line', magic_name='rdm_get_user_profile')
    ipython.register_magic_function(rdm_get_user_hotp, 'line', magic_name='rdm_get_user_hotp')
    ipython.register_magic_function(rdm_list_collections, 'line', magic_name='rdm_list_collections')

def unload_ipython_extension(ipython):
    ipython.drop_by_id('rdm')
    pass

## magic functions
def rdm_account(line):
    """(re-)set RDM data-access credential"""
    p = argparse.ArgumentParser(description='(Re-)set the RDM data-access credential', prog='rdm_account')

    p.add_argument('-u',
          metavar = 'username',
          dest    = 'username',
          action  = 'store',
          type    = str,
          default = irdm.irods_username,
          help    = 'the RDM data-access account')

    p.add_argument('-p',
          metavar = 'password',
          dest    = 'password',
          action  = 'store',
          type    = str,
          default = irdm.irods_password,
          help    = 'the RDM data-access password')

    # reset user name and password
    args = p.parse_args(line.split())
    irdm.irods_password = args.username
    irdm.irods_password = args.password

def rdm_list(line):
    """list folders and files within a RDM collection"""

    p = argparse.ArgumentParser(description='(Re-)set the RDM data-access credential', prog='rdm_list')

    p.add_argument('identifier',
          metavar = 'identifier',
          help    = 'collection identifier')

    p.add_argument('-r',
          dest    = 'recursive',
          action  = 'store_true',
          default = False,
          help    = 'list collection content recursively')

    args = p.parse_args(line.split())

    # list files in a given collection
    irods_files = []
    for f in irdm.ls(ns_collection='rdmtst/%s' % '/'.join(args.identifier.split('.', 2)), rel_path='', recursive=args.recursive):
        irods_files.append( {'TYPE': f.TYPE,
                             'PATH': f.PATH,
                             'OWNER': f.OWNER,
                             'SIZE': str(f.SIZE)} )

    t = makeTabular('', irods_files, ['TYPE','PATH','OWNER','SIZE'], ['TYPE','PATH','OWNER','SIZE'], ',')
    print(t.table.encode('utf-8'))

def rdm_get_user_profile(line):
    """run RDM UI rules to get current user profile"""

    out = irdm.__rdm_exec_rule__('/home/hclee/Projects/rdm-irods-rules/irods/rules/ui/getUser.r', {'userName': irdm.irods_username}, admin=False)

    print json.dumps(out, indent=4)

def rdm_get_user_hotp(line):
    """run RDM UI rules to get current user's next HOTP"""

    out = irdm.__rdm_exec_rule__('/home/hclee/Projects/rdm-irods-rules/irods/rules/ui/getUserNextHOTP.r', {'userName': irdm.irods_username}, admin=False)

    print json.dumps(out, indent=4)

def rdm_list_collections(line):
    """run RDM UI rules to list collections accessible to the current user"""

    out = irdm.__rdm_exec_rule__('/home/hclee/Projects/rdm-irods-rules/irods/rules/ui/getListOfCollections.r', {'mode': 'user'}, admin=False)

    for c in out['collections']:
        print('%s:%s:%s' % (c['collectionIdentifier'],c['collName'],c['title']))
