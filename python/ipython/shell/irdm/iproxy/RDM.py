#!/usr/bin/env python
from __future__ import print_function
try:
    # for IPython4
    from traitlets.config.configurable import Configurable
    from traitlets import List, Int, Unicode
except ImportError:
    # backward compatible with IPython3 
    from IPython.config.configurable import Configurable
    from IPython.utils.traitlets import Bool, List, Int, Unicode
from IPython import get_ipython

import sys
import os 
sys.path.append(os.environ['DCCN_PYTHONDIR'] + '/lib')
sys.path.append(os.environ['DCCN_PYTHONDIR'] + '/external')
from rdm.IRDM import *
from common.Utils import makeTabular,makeAttributeValueTable
from common.Logger import getLogger

class RDM(Configurable):

    irods_config = Unicode(os.path.join(os.path.expanduser('~'), '.irods/irdm/config.ini'), config=True)
    irods_iftype = Unicode('icommand', config=True)
    log_level = Int(0, config=True)

    # configuration for tabular display
    tab_coll_header = List(['identifier', 'v:2', 'title:25', 'state', 'managers', 'contributors', 'viewers'], config=True)
    tab_coll_dattrs = List(['collectionIdentifier', 'versionNumber', 'title', 'state', 'manager.displayName', 'contributor.displayName', 'viewer.displayName'], config=True)

    tab_user_header = List(['display name', 'home organisation', 'OU user', 'OU admin', 'data access uid'], config=True)
    tab_user_dattrs = List(['displayName', 'homeOrganisation', 'organisationalUnit', 'isAdminOf', 'irodsUserName'], config=True)

    # configuration for collection attribute display
    coll_displayed_dattrs = List(['collectionIdentifier','identifierEPIC','identifierDOI','versionNumber','collName','title','descriptionAbstract','type','state','publisher','organisation','organisationalUnit','projectId','manager','contributor','viewer','contactPerson','creatorList','keyword_freetext','keyword_MeSH2015','keyword_SFN2013','associatedDAC','associatedRDC','associatedDSC','associatedPublication','ethicalApprovalIdentifier','creationDateTime','attributeLastUpdatedDateTime','embargoUntilDateTime','dataUseAgreement'], config=True)

    user_displayed_dattrs = List(['displayName','givenName','surName','email','homeOrganisation','organisationalUnit','isAdminOf','researcherId','openResearcherAndContributorId','personalWebsiteUrl'], config=True)

    def __init__(self, config=None):
        super(RDM, self).__init__(config=config)

        self.logger = getLogger('RDM', lvl=self.log_level)

        if not os.path.exists(self.irods_config):
            self.irods_config = os.environ['DCCN_PYTHONDIR'] + '/config/rdm-config.ini'

        if self.irods_iftype == 'icommand':
            self.rdm = IRDMIcommand(config=self.irods_config, login=False, lvl=self.log_level)
        else:
            self.rdm = IRDMRestful(config=self.irods_config, lvl=self.log_level)

        try:
            self.user_login()
        except Exception, e:
            pass

    def __del__(self):
        """
        destructor function
        """
        # delete the underlying RDM object to cleanup temporary files/caches
        del self.rdm

    def user_get(self, irodsUserName=None):
        """get user profile object from iRODS"""

        if not irodsUserName:
            irodsUserName = self.rdm.config.get('RDM', 'irodsUserName')

        rule_script = os.environ['IRDM_PREFIX'] + '/rules/getUser.r'
        inputs = {'userName': irodsUserName}

        out = self.rdm.__rdm_exec_rule__(rule_script, inputs, admin=self.__is_admin_mode__())

        if out['ec'] != 0:
            self.logger.error('fail retrieving user %s: %s' % (irodsUserName, out['errmsg']))

        return out['profile']

    def user_profile(self):
        """ get user profile 
        """
        data = self.user_get()

        t = makeTabular('User profile', [data], self.tab_user_dattrs, self.tab_user_header, ',')
        print(t.table.encode('utf-8'))

        return True

    def user_find(self, clause):
        """
        find user matching the provided clause
        :param clause: the clause for matching user profile
        :return:
        """
        rule_script = os.environ['IRDM_PREFIX'] + '/rules/findUser.r'
        inputs = {'kv_str': clause}

        out = self.rdm.__rdm_exec_rule__(rule_script, inputs, admin=True)

        if out['ec'] != 0:
            self.logger.error('fail finding user with %s: %s' % (clause, out['errmsg']))
            return False

        t = makeTabular('user profiles', out['users'], self.tab_user_dattrs, self.tab_user_header, ',')
        print(t.table.encode('utf-8'))

        return True

    def user_attrs(self, irodsUserName=None):
        """ get user attributes
        """

        data = self.user_get(irodsUserName)

        ## make a nice-looking table
        t = makeAttributeValueTable('', data, attrs_to_show=self.user_displayed_dattrs)
        print(t.table.encode('utf-8'))

        return True

    def user_update(self, kv_str, irodsUserName=None):
        """
        updates user attribute with provided kv_str
        :param kv_str: the string representation of key-value pairs
        :param irodsUserName: the iRODS user name of the targeting user
        :return: the 'ec' and 'errmsg' tuple returned from the 'updateUserProfile.r' iRODS rule
        """

        rule_script = os.environ['IRDM_PREFIX'] + '/rules/updateUserProfile.r'

        inputs = {'kv_str': ('irodsUserName=' + irodsUserName + '%' + kv_str.decode('utf-8')).encode('utf-8')}
        out = self.rdm.__rdm_exec_rule__(rule_script, inputs, admin=False)

        return out['ec'], out['errmsg']

    def user_logout(self):
        """ user logout
        """
        self.rdm.logout()
        get_ipython().user_ns['_rdm_mystate'].is_user_login = self.rdm.is_user_login
        return True

    def user_login(self):
        """ user login
        """
        self.rdm.login()
        get_ipython().user_ns['_rdm_mystate'].is_user_login = self.rdm.is_user_login
        return True

    def user_nextotp(self):
        """ get user's next one-time password 
        """
        rule_script = os.environ['IRDM_PREFIX'] + '/rules/getUserNextHOTP.r'
        inputs = {'userName': self.rdm.config.get('RDM', 'irodsUserName')}

        out = self.rdm.__rdm_exec_rule__(rule_script, inputs, admin=False)

        print(out['otp'])

        return out['ec']

    def coll_goto(self, identifier, version=0):
        """ goto a collection
        """

        _cached_colls = get_ipython().user_ns['_rdm_mystate'].my_colls

        # if cache is empty, load the list of collections
        if not _cached_colls:
            self.__get_coll_list__()
            _cached_colls = get_ipython().user_ns['_rdm_mystate'].my_colls

        # locate the collection
        _my_coll = filter( lambda x:x[0] == identifier and x[1] == version, _cached_colls )

        if _my_coll:
            get_ipython().user_ns['_rdm_mystate'].cur_coll = _my_coll[0][2]
            get_ipython().user_ns['_rdm_mystate'].cur_coll_path = ''

            if type(self.rdm) is IRDMIcommand:
                ## determine iRODS namespace to move the underlying shell
                _coll_name = _my_coll[0][3]
                self.rdm.shell.cmd1('icd %s' % _coll_name)
                self.rdm.admin_shell.cmd1('icd %s' % _coll_name)
        else:
            raise ValueError('collection not found: %s v%d' % (identifier, version))

        return True

    def coll_goto_home(self):
        """ move to the top-level namespace of iRODS
        :return:
        """
        get_ipython().user_ns['_rdm_mystate'].cur_coll = ''
        get_ipython().user_ns['_rdm_mystate'].cur_coll_path = ''

        if type(self.rdm) is IRDMIcommand:
            self.rdm.shell.cmd1('icd')
            self.rdm.admin_shell.cmd1('icd')

    def coll_list(self):
        """ list collections
        """

        out = self.__get_coll_list__()
 
        t = makeTabular('Collections', out['collections'], self.tab_coll_dattrs, self.tab_coll_header, '\n')
        print(t.table.encode('utf-8'))

        return out['ec']

    def coll_icd(self, path):
        """ move working directory within a collection
        """

        _coll_name = self.__get_curr_coll_name__()
        _coll_path = get_ipython().user_ns['_rdm_mystate'].cur_coll_path

        ## make it absolute path
        if not os.path.isabs(path):
            path = os.path.abspath(os.path.join(os.path.join(_coll_name, _coll_path), path))
       
        if path.find(_coll_name) != 0:
                raise ValueError('cannot move outside current collection, goto another collection first')

        if type(self.rdm) is IRDMIcommand:
            self.icommand_run('icd %s' % path)
        else:
            # TODO: try to probe the existence of the path with IRDMRestful
            pass

        get_ipython().user_ns['_rdm_mystate'].cur_coll_path = path.replace(_coll_name, '').lstrip('/')

    def coll_ls(self):
        """list current path within current collection"""
        _coll_name = self.__get_curr_coll_name__()
        _coll_path = get_ipython().user_ns['_rdm_mystate'].cur_coll_path

        return self.rdm.ls(_coll_name, _coll_path, recursive=False)

    def coll_mkdir(self, rel_path):
        """recursively make directories relative to the current path within current collection"""

        if os.path.isabs(rel_path):
            self.logger.error('not a relative path: %s' % rel_path)
            return False

        _coll_name = self.__get_curr_coll_name__()
        _coll_path = get_ipython().user_ns['_rdm_mystate'].cur_coll_path

        return self.rdm.mkdir(_coll_name, os.path.join(_coll_path, rel_path))

    def coll_get(self):
        """get current collection object"""

        _coll_name = self.__get_curr_coll_name__()
        rule_script = os.environ['IRDM_PREFIX'] + '/rules/getCollection.r'
        inputs = {'kv_str': str('collName=%s' % _coll_name)}
        out = self.rdm.__rdm_exec_rule__(rule_script, inputs, admin=False)

        if out['ec'] != 0:
            self.logger.error('fail retrieving collection: %s' % out['errmsg'])

        return out['collection']

    def coll_attrs(self):
        """ get list of collection attributes
        """
        data = self.coll_get()

        if not data:
            return False

        ## manipulate value of certain attributes
        for k in ['associatedDAC','associatedRDC','associatedDSC']:
            if k in data.keys() and data[k]:
                nv = []
                for v in filter(lambda x:'title' in x.keys(), data[k]):
                    nv.append('%s (title: %s, state:%s)' % (v['collectionIdentifier'],v['title'],v['state']))
                cnt_no_perm = len(filter(lambda x:'title' not in x.keys(), data[k]))
                if cnt_no_perm:
                    nv.append('+ %d collections not authorised to you' % cnt_no_perm)
                data[k] = nv

        for k in ['manager','contributor','viewer']:
            if data[k]:
                nv = []
                for v in filter(lambda x:x, data[k]):
                    nv.append('%s (%s)' % (v['displayName'],v['irodsUserName']))
                data[k] = nv

        if data['contactPerson']:
            v = data['contactPerson']
            nv = '%s (%s, mailto:%s)' % (v['displayName'], v['irodsUserName'], v['email'])
            data['contactPerson'] = nv

        ## make a nice-looking table 
        t = makeAttributeValueTable('', data, attrs_to_show=self.coll_displayed_dattrs)
        print(t.table.encode('utf-8'))

        return True

    def coll_update(self, kv_str):
        """
        updates collection attribute with provided kv_str
        :param kv_str: the string representation of key-value pairs
        :return: the 'ec' and 'errmsg' tuple returned from the 'updateCollectionMetadata.r' iRODS rule
        """

        _coll_name = self.__get_curr_coll_name__()

        rule_script = os.environ['IRDM_PREFIX'] + '/rules/updateCollectionMetadata.r'

        inputs = {'kv_str': ('collName=' + _coll_name + '%' + kv_str.decode('utf-8')).encode('utf-8')}
        out = self.rdm.__rdm_exec_rule__(rule_script, inputs, admin=False)

        return out['ec'], out['errmsg']

    def coll_create(self, kv_str):
        """
        create collection with attributes given as the kv_str
        :param kv_str: the string representation of key-value pairs
        :return: the 'ec', 'errmsg' and 'collection' tuple returned from the 'createCollection.r' iRODS rule
        """
        rule_script = os.environ['IRDM_PREFIX'] + '/rules/createCollection.r'
        inputs = {'kv_str': kv_str}
        out = self.rdm.__rdm_exec_rule__(rule_script, inputs, admin=False)

        return out['ec'],out['errmsg'],out['collection']

    def icommand_run(self, cmd, admin=False):
        """ pass icommand to underlying shell and print output 
        """
        if admin:
            output = self.rdm.__exec_shell_cmd__(cmd, admin=True)
        else:
            output = self.rdm.__exec_shell_cmd__(cmd, admin=self.__is_admin_mode__())
        print (output)
        return True 

    def display(self):
        print('irods_config: ', self.irods_config)
        print('irods_iftype: ', self.irods_iftype)
        print('log_level: '   , self.log_level)

    def __get_curr_coll_name__(self):
        """ internal method to get the namespace of current collection 
        """
        _cur_coll = get_ipython().user_ns['_rdm_mystate'].cur_coll
        if not _cur_coll:
            raise ValueError('goto a collection first')

        # locate the collection namespace
        _my_coll = filter(lambda x:x[2] == _cur_coll, get_ipython().user_ns['_rdm_mystate'].my_colls)

        return _my_coll[0][3]

    def __is_admin_mode__(self):
        """ determine whether the user is in his admin mode.
            This should be distinguished from the 'admin' shell, that is refers to 
            the useage of iRODS admin for exiecuting iCommands. 
        """
        return get_ipython().user_ns['_rdm_mystate'].is_admin_mode

    def __get_coll_list__(self):
        """ internal method to get a list of collecitons using irule
        """

        rule_script = os.environ['IRDM_PREFIX'] + '/rules/getListOfCollections.r'

        # determin the mode
        mode = 'user'
        if self.__is_admin_mode__():
            mode = 'admin'

        inputs = {'mode': mode}

        out = self.rdm.__rdm_exec_rule__(rule_script, inputs, admin=False)

        # cache collection identifiers
        get_ipython().user_ns['_rdm_mystate'].update_my_colls(out['collections'])
       
        return out
