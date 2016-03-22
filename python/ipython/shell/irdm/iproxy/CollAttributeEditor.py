#!/usr/bin/env python

from AttributeEditor import AttributeEditor
from RDM import RDM

class CollAttributeEditor(AttributeEditor):

    def __init__(self, rdm_proxy):
        """
        Constructor of CollAttributeEditor
        :param irdm: the RDM IPython proxy object
        :return:
        """
        AttributeEditor.__init__(self, prompt='Coll Editor: ', target={})
        if type(rdm_proxy) is RDM:
            self.rdm_proxy = rdm_proxy
            self.target = self.rdm_proxy.coll_get()
        else:
            raise TypeError('invalid RDM proxy object: %s' % type(rdm_proxy))

    def do_attrs(self, line):
        """
        Shows the up-to-date collection attributes and their values
        """
        self.rdm_proxy.coll_attrs()

    def commit_changes(self):
        """
        Commits attribute changes to the RDM system
        :return: True on success, otherwise False
        """

        ec, errmsg = self.rdm_proxy.coll_update(self.get_kv_str())

        if ec != 0:
            self.logger.error(errmsg)
            return False
        else:
            return True
