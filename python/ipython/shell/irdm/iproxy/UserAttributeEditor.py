#!/usr/bin/env python

from AttributeEditor import AttributeEditor
from RDM import RDM

class UserAttributeEditor(AttributeEditor):

    def __init__(self, rdm_proxy, irodsUserName=None):
        """
        Constructor of UserAttributeEditor
        :param rdm_proxy: the RDM IPython proxy object
        :param irodsUserName: the iRODS user name of the targeting user
        :return:
        """
        AttributeEditor.__init__(self, prompt='User Editor: ', target={})
        if type(rdm_proxy) is RDM:
            self.rdm_proxy = rdm_proxy
            self.target = self.rdm_proxy.user_get(irodsUserName)
        else:
            raise TypeError('invalid RDM proxy object: %s' % type(rdm_proxy))

    def do_attrs(self, line):
        """
        Shows the up-to-date collection attributes and their values
        """
        self.rdm_proxy.user_attrs(self.target['irodsUserName'])

    def commit_changes(self):
        """
        Commits attribute changes to the RDM system
        :return: True on success, otherwise False
        """

        ec, errmsg = self.rdm_proxy.user_update(self.get_kv_str(), self.target['irodsUserName'])

        if ec != 0:
            self.logger.error(errmsg)
            return False
        else:
            return True
