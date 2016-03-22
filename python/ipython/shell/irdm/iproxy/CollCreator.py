#!/usr/bin/env python

from AttributeEditor import AttributeEditor
from RDM import RDM
import re
import shlex

class CollCreator(AttributeEditor):

    required_attrs = set(['projectId','manager','organisation','organisationalUnit','title','type','quotaInMegaBytes'])

    def __init__(self, rdm_proxy):
        """
        Constructor of CollAttributeEditor
        :param irdm: the RDM IPython proxy object
        :return:
        """
        AttributeEditor.__init__(self, prompt='Coll Creator: ', target={})
        if type(rdm_proxy) is RDM:
            self.rdm_proxy = rdm_proxy
        else:
            raise TypeError('invalid RDM proxy object: %s' % type(rdm_proxy))

    def do_attrs(self, line):
        # here we don't have any target object to show as the collection is not created.
        # TODO: find a way to show kv_str in a more object-oriented way as the target object.
        return self.get_kv_str()

    def postcmd(self, stop, line):
        """overwrite to quit the creator after collection is successfully created"""

        if line and shlex.split(line)[0] == 'commit':
            # for the moment, self.target is the indication of a successful creation
            if self.target:
                return True
            else:
                return False

        return AttributeEditor.postcmd(self, stop, line)

    def get_kv_str(self):
        """overwrite get_kv_str to strip off the 'rm' actions"""
        kv_str = AttributeEditor.get_kv_str(self)
        return '%'.join(filter(lambda x:not re.match('.*=_rm:.*', x), kv_str.split('%')))

    def commit_changes(self):
        """commit to create collection"""

        # perform checks on mandatory attributes
        kv_str = self.get_kv_str()
        attrs = set(map(lambda x:x.split('=')[0], kv_str.split('%')))

        missing_attrs = self.required_attrs - attrs
        if missing_attrs:
            self.logger.error('missing mandatory attributes: %s', ','.join(missing_attrs))
            return False

        ec, errmsg, self.target = self.rdm_proxy.coll_create(self.get_kv_str())

        if ec == 0:
            print('collection created: %s' % self.target['collectionIdentifier'])
            return True
        else:
            self.logger.error(errmsg)
            return False
