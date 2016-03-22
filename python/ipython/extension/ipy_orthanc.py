#!/usr/bin/env ipython
import os 
import sys
import argparse
from datetime import date, datetime, timedelta
sys.path.append('%s/external' % os.environ['DCCN_PYTHONDIR'])
sys.path.append('%s/lib' % os.environ['DCCN_PYTHONDIR'])
from orthanc.IOrthanc import IOrthanc
from orthanc.WorklistManager import WorklistManager
from common.Utils import makeTabular

iorthanc = IOrthanc(config='%s/config/mr-config.ini' % os.environ['DCCN_PYTHONDIR'])
wlmgr = WorklistManager(config='%s/config/mr-config.ini' % os.environ['DCCN_PYTHONDIR'])

def load_ipython_extension(ipython):
    ipython.register_magic_function(pacs, 'line', magic_name='pacs')
    ipython.register_magic_function(wklst, 'line', magic_name='wklst')

def unload_ipython_extension(ipython):
    ipython.drop_by_id('pacs')
    pass

## magic functions
def wklst(line):
    """implements interfaces to WorklistManager"""

    def valid_date(s):

        if not s:
            return date.today()
        
        try:
            return datetime.strptime(s, "%Y-%m-%d")
        except ValueError:
            msg = "Not a valid date: '{0}'.".format(s)
            raise argparse.ArgumentTypeError(msg)

    p = argparse.ArgumentParser(description='retrieve DICOM worklist', prog='wklst')
    p.add_argument('-d',
          metavar = 'date',
          dest    = 'date',
          action  = 'store',
          type    = valid_date,
          default = '',
          help    = 'date in %Y-%m-%d format, e.g. 2016-01-01')

    args = p.parse_args(line.split())

    print wlmgr.getWorklistItems(eDate = args.date)

def pacs(line):
    """implements interfaces to Orthanc PACS server"""
    print('%s' % line)

    t_end = datetime.now()
    t_beg = t_end - timedelta(minutes=60*24)
    data = []
    for d in iorthanc.getStudies(last_update_range=[t_beg, t_end]):
        # Example output of a study:
        #    {u'IsStable': True, u'MainDicomTags': {u'AccessionNumber': u'(null)', u'StudyDate': u'20160314', u'StudyInstanceUID': u'1.3.12.2.1107.5.2.43.67027.30000016031410142103000000013', u'StudyDescription': u'VanvAst^PrismaFit', u'StudyTime': u'161332.427000', u'StudyID': u'1'}, u'LastUpdate': u'20160314T163759', u'Series': [u'cf51677e-c508ab49-7921dfce-5ae09f3c-00451d2e', u'feb97b72-eadf96d1-205d904d-afee1edd-d6cfc889', u'254a3a91-9c44febe-98f3a3ff-5325dc5b-8b8e0214', u'7f947cfe-31be55f4-a4f74399-9973d10d-e9eb3009', u'e6691a04-987ba329-224c49d9-e3301eea-679f5d3a', u'5fbee4e3-26618649-fe05f878-b5f3c315-795190d3', u'06693112-e8225238-79f55a43-24a31d13-4486d5b4', u'dc6b906f-92b785f6-5ccdeb16-2be6f133-7abb6da1'], u'Type': u'Study', u'ID': u'cfedc5c0-0cc2da06-a09e1074-203abbb9-53291ed6', u'ParentPatient': u'd3c833a6-b261e515-9be61827-32618d62-443773a1'}
        data.append( {'id'         : d.ID,
                      'description': d.MainDicomTags.StudyDescription,
                      'date'       : d.MainDicomTags.StudyDate,
                      'time'       : d.MainDicomTags.StudyTime } )

    t = makeTabular('', data, ['id','stable','description','date','time'], ['id','stable','description','date','time'], ',')
    print(t.table.encode('utf-8'))
