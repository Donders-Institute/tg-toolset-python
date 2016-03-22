#!/usr/bin/env python

from __future__ import print_function
import argparse
import shlex
import re
from cmd import Cmd
from common.Logger import getLogger

class AttributeEditor(Cmd):

    def __init__(self,prompt='editor: ', target={'attr1':'val1','attr2':'val2'}):
        Cmd.__init__(self)
        self.kvp_list = {'add':set([]),'set':set([]),'rm':set([])}
        self.cmd_parser = argparse.ArgumentParser()
        self.cmd_parser.add_argument('kvp', type=str, nargs='+')
        self.prompt = prompt
        self.target = target
        self.logger = getLogger('AttributeEditor', lvl=0)

    def default(self, argv):
        return self.do_help(argv)

    def do_help(self, argv):

        msg = ''
        if argv == 'set':
            msg = """ 
Add attribute-value pairs from the RDM object

Usage:
    set 'attr1=val1' ['attrN=valN']
"""
        elif argv == 'add':
            msg = """ 
Add attribute-value pairs from the RDM object

Usage:
    add 'attr1=val1' ['attrN=valN']
"""
        elif argv == 'rm':
            msg = """ 
Remove attribute-value pairs from the RDM object

Usage:
    rm 'attr1=val1' ['attrN=valN']
"""
        elif argv == 'attrs':
            msg = """ 
Print attribute-value pairs of the RDM object
"""
        elif argv == 'commit':
            msg = """ 
Commit changes to the RDM object
"""
        elif argv == 'diff':
            msg = """ 
Print changes to be made on the RDM object in form of a kv_str
"""
        else:
            msg = """
Supported actions:

  * set    : set attribute-value pairs to the RDM object (i.e. User or Collection)
  * add    : add attribute-value pairs to the RDM object
  * rm     : remove attribute-value pairs from the RDM object
  * attrs  : print attribute-value pairs of the RDM object
  * diff   : print changes to be made on the RDM object in form of a kv_str
  * commit : commit changes to the RDM object
"""
        print(msg)
 
    def do_set(self, argv):
        pass

    def do_add(self, argv):
        pass

    def do_rm(self, argv):
        pass

    def do_diff(self, argv):
        print('-> uncommitted changes: %s' % self.get_kv_str())

    def do_nothing(self, argv):
        pass

    def do_attrs(self, argv):
        print('available attributes:')
        for k in self.target.keys():
            print(' * %s' % k)

    def do_commit(self, argv):

        if self.commit_changes():
            # flush kvp_list
            self.kvp_list['add'] = set([])
            self.kvp_list['set'] = set([])
            self.kvp_list['rm'] = set([])
        else:
            self.logger.error('failed to commit changes: %s' % self.get_kv_str())

    def precmd(self, line):
        # here validation of value can be performed,
        # and return 'nothing' if value is invalid

        if True:
            return line
        else:
            return 'nothing'

    def postcmd(self, stop, line):

        if line:
            line_data = shlex.split(line)
            act = line_data[0]
            if act in ['set','add','rm'] and line_data[1:]:
                line_args = self.cmd_parser.parse_args(line_data[1:])
                # join the existing kvp_list, and remove redudent kvp
                self.kvp_list[act].update(set(line_args.kvp))
                print('-> uncommitted changes: %s' % self.get_kv_str())
            else:
                pass
        
        return stop

    def do_EOF(self, argv):
        print()
        return True

    def do_exit(self, argv):
        return True

    def get_kv_str(self):

        ## resolve common parts between three actions 
        kvp_add_set = (self.kvp_list['add'] | self.kvp_list['set']) - self.kvp_list['rm']
        kvp_rm      = self.kvp_list['rm'] - (self.kvp_list['add'] | self.kvp_list['set'])

        ## refresh kvp_list to reflect the actuall, meaningful actions
        self.kvp_list['add'] = set([])
        self.kvp_list['set'] = kvp_add_set
        self.kvp_list['rm']  = kvp_rm

        ## compose kv_str
        kv_str = '%'.join(list(kvp_add_set) + map(lambda x:x.replace('=','=_rm:',1),kvp_rm))

        return kv_str

    def commit_changes(self):
        """actual action to apply changes to target"""
        return False

class DummyAttributeEditor(AttributeEditor):

    def commit_changes(self):
        """simply update the self.target object with the changes"""
        for kvp in self.get_kv_str().split('%'):
            (k,v) = kvp.split('=', 1)
            if re.match('^_rm:',v):
                # remove k:v pair from self.target
                v = re.sub('^_rm:','',v)
                if k in self.target.keys() and self.target[k] == v:
                    del(self.target[k])
            else:
                # set k:v pair to self.target
                self.target[k] = v

        return True
