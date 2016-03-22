#!/usr/bin/env python
class RDMState(object):
    '''a state object caching current client status'''
    cur_user = ""
    cur_coll = ""
    is_user_login = False
    is_admin_mode = False
    my_colls = []

    # Cache for attribute editors
    coll_editors = []
    user_editors = []

    def update_my_colls(self, collections):
        '''cache the collection identifiers'''
        self.my_colls = []
        for c in collections:

            #just an artificial number for head version
            v = 0
            try:
                v = int(c['versionNumber'])
            except KeyError, e:
                pass
 
            self.my_colls.append((c['collectionIdentifier'], v, c['collId'], c['collName']))

    def flush(self):
        self.cur_coll = ''
        self.my_colls = []
        self.user_editors = []
        self.coll_editors = []

    def cur_coll_identifier(self):
        _id = ''
        _coll = filter(lambda x:x[2] == self.cur_coll, self.my_colls)
        if _coll:
            _id = _coll[0][0]
            if _coll[0][1]:
                _id += ':v%d' % _coll[0][1]
        return _id

    def __shell_prompt__(self):
        if not self.is_user_login:
            return '{color.LightRed}['+ self.cur_user + '@' + self.cur_coll_identifier() + ']\niRDM[\\N]: '
        elif self.is_admin_mode:
            return '{color.Purple}['+ self.cur_user + '@' + self.cur_coll_identifier() + '][ADMIN]\niRDM[\\N]: '
        else:
            return '{color.Green}['+ self.cur_user + '@' + self.cur_coll_identifier() + ']\niRDM[\\N]: '

    def __str__(self):
            return self.cur_user + '@' + self.cur_coll_identifier()

_rdm_mystate = RDMState()

del RDMState
