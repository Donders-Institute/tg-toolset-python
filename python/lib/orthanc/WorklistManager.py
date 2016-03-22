#!/usr/bin/env python
from common.Logger import getLogger
from common.IMySQL import IMySQL
from datetime import datetime, date, timedelta
from Cheetah.Template import Template
import ConfigParser

class WorklistItem(object):

    def __init__(self, projectId, projectTitle, subjectId, sessionId, date, time, scanner, physician):
        self.projectId = projectId
        self.projectTitle = projectTitle
        self.subjectId = subjectId
        self.sessionId = 'SESS%s' % sessionId.zfill(2)
        self.sessionTitle = 'session %s' % sessionId.zfill(2)
        self.date = date
        self.time = time
        self.physician = physician
        self.eventId = time.lstrip('0')   # evenId is taken from time with leading zero stripped

        self.modalityAE = scanner
        self.patientId = '%s_SUBJ%s' % (projectId, subjectId.zfill(4))
        self.studyId = '%s_S%s' % (projectId, sessionId.zfill(2))

    def getWorklistTemplate(self):
        """worklist template for Cheetah template engine"""

        worklist_tmpl ="""(0010,0010) PN  [$e['patientId']]
(0010,0020) LO  [$e['patientId']]
(0020,000d) UI  [$e['eventId']]
(0032,1032) PN  [$e['physician']]
(0032,1060) LO  [$e['projectTitle']]
(0040,1001) SH  [$e['sessionId']]
(0040,0100) SQ
(fffe,e000) -
(0008,0060) CS  [MR]
(0040,0001) AE  [$e['modalityAE']]
(0040,0002) DA  [$e['date']]
(0040,0003) TM  [$e['time']]
(0040,0009) SH  [$e['studyId']]
(0040,0010) SH  [$e['modalityAE']]
(0040,0011) SH  [DCCN]
(0040,0007) LO  [$e['sessionTitle']]
(0040,0008) SQ
(fffe,e0dd) - 
(fffe,e00d) -
(fffe,e0dd) -
"""

        return worklist_tmpl

    def __cmp__(self, other):
        """compare ModalityWorklist by date + time + patientId"""
        if not isinstance(other, ModalityWorklist):
            raise NotImplementedError
        return cmp(self.date, other.date) and cmp(self.time, other.time) and cmp(self.patientId, other.patientId)

    def __repr__(self):
        return str(Template(self.getWorklistTemplate(), searchList={'e': self.__dict__}))

class WorklistManager:

    def __init__(self, config):
        """
        class initializer
        :param config: configuration file for WorklistManager 
        :return:
        """

        cfg = ConfigParser.ConfigParser()
        cfg.read(config)
        self.logger = getLogger(name=self.__class__.__name__, lvl=int(cfg.get('LOGGING', 'level')))

        self.__getDBConnectInfo__(cfg)
        self.pdb = IMySQL(db_host = self.pdb_host,
                          db_username = self.pdb_uid,
                          db_password = self.pdb_pass,
                          db_name = self.pdb_name)

    def __del__(self):
        self.pdb.closeConnector()

    def __getDBConnectInfo__(self, cfg):
        '''common function to get database connection information
        '''
        ## project database connection information
        self.pdb_host   = cfg.get('PACS','pdb_hostname') 
        self.pdb_uid    = cfg.get('PACS','pdb_username') 
        self.pdb_pass   = cfg.get('PACS','pdb_password')
        self.pdb_name   = cfg.get('PACS','pdb_dbname')
 
        if not self.pdb_pass:
            ## try ask for password from the interactive shell
            if sys.stdin.isatty(): ## for interactive password typing
                self.pdb_pass = getpass.getpass('Project DB password: ')
            else: ## for pipeing-in password
                print 'Project DB password: '
                self.pdb_pass = sys.stdin.readline().rstrip()

    def getWorklistItems(self, eDate=date.today()):
        '''compose worklist items based on booking events retrieved from calendar table in PDB
        '''

        conn = self.pdb.getConnector()
        crs  = None

        worklist = []

        try:
            qry = 'SELECT a.id,a.calendar_id,a.project_id,a.subj_ses,a.start_date,a.start_time,a.user_id,b.projectName FROM calendar_items_new as a, projects as b WHERE a.status = \'CONFIRMED\' and a.subj_ses like \'%%-%%\' and a.start_date = DATE(\'%s\') and a.project_id = b.id ORDER BY a.start_time' % eDate.strftime('%Y-%m-%d')

            self.logger.debug(qry)

            crs = conn.cursor()
            rslt = crs.execute(qry)

            for (eId, calendarId, projectId, subj_ses, startDate, startTime, userId, projectName) in crs.fetchall():
   
                d = subj_ses.split()
                subjectId = d[0]
                sessionId = d[-1]

                # in some MySQL library, the startTime is returned as timedelta object
                eStartTime = None
                if type(startTime) is timedelta:
                    eStartTime = datetime(startDate.year, startDate.month, startDate.day)
                    eStartTime += startTime
                else:
                    eStartTime = startTime 
 
                wl = WorklistItem(projectId,
                                  projectName,
                                  subjectId,
                                  sessionId,
                                  startDate.strftime('%Y%m%d'),
                                  eStartTime.strftime('%H%M%S'),
                                  calendarId,
                                  userId)

                worklist.append(wl)

        except Exception, e:
            self.logger.exception('Project DB select failed')
        else:
            ## everything is fine
            self.logger.info('Project DB select succeeded')
        finally:
            ## close db cursor
            try:
                crs.close()
            except Exception, e:
                pass

            self.pdb.closeConnector()

        return worklist
