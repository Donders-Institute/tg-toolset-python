#!/usr/bin/env python
from argparse import ArgumentParser
import hashlib

import os
import sys
import time
import datetime
import tempfile

sys.path.append(os.path.dirname(os.path.abspath(__file__))+'/../lib/external')
sys.path.append(os.path.dirname(os.path.abspath(__file__))+'/../lib')
from Logger import getLogger
from IOrthanc import IOrthanc
from IRDM import IRDMRestful, IRDMIcommand, IRDMException
from MTRunner import MTRunner, Algorithm, Data


class DataStreamingAlgorithm(Algorithm):

    def __init__(self):
        Algorithm.__init__(self)
        self.rdm_coll_ns = None
        self.rdm_datadir_rel = 'raw'
        self.rdm_imode = 'icommands'
        self.irdm = None
        self.config = os.path.dirname(os.path.abspath(__file__)) + '/../etc/config.ini'

    def update_progress(self, progress):
        print '\r[{0}] {1}%'.format('#'*(progress/10), progress)

    def __get_irdm__(self):
        """
        initiate and configure the RDM interface object, make sure there is only one interface object
        """ 
        if not self.irdm:
            if self.rdm_imode in ['icommands']:
                self.irdm = IRDMIcommand(self.config, lvl=3)
            else:
                self.irdm = IRDMRestful(self.config, lvl=3)

    def process(self, study):

        #dest_fpath = os.path.join(tempfile.gettempdir(), 's_%s_%s.zip' % (study.MainDicomTags.StudyTime, study.ID))

        print study

        dest_fpath = os.path.join(tempfile.gettempdir(), 's_%s_%s.zip' % (study.MainDicomTags.StudyDescription, study.MainDicomTags.StudyTime))

        profile = {'time_profile': datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                   'time_getarchive': None,
                   'time_rdmput': None,
                   'file_size': None}

        t = time.time()
        ick = o.getArchive('studies/%s' % study.ID, dest_fpath, checksum=True)
        profile['time_getarchive'] = time.time() - t

        if ick:
            # get file size in bytes
            profile['file_size'] = os.path.getsize(dest_fpath)
            if self.rdm_coll_ns:
                try:

                    self.__get_irdm__()

                    self.irdm.mkdir(self.rdm_coll_ns, self.rdm_datadir_rel)
                    t = time.time()
                    self.irdm.put(src_path=dest_fpath,
                             ns_collection=self.rdm_coll_ns,
                             rel_path=os.path.join(self.rdm_datadir_rel,study.MainDicomTags.StudyDate), show_progress=False)
                    profile['time_rdmput'] = time.time() - t
                except IRDMException, e:
                    ick = False
                else:
                    # remove archive file from local disk in any case (space saving)
                    if os.path.exists(dest_fpath):
                        os.unlink(dest_fpath)

        # append profile to the algorithm results if the process is done successfully
        if ick:
            self.__appendResult__(study.ID, profile)

        return ick


class DataStreamer(MTRunner):

    def __init__(self, numThread=2, keepAlive=False, studies=[]):
        MTRunner.__init__(self,
                          name='orthanc2rdm_streamer',
                          data=Data(collection=studies),
                          algorithm=DataStreamingAlgorithm())

        # specify number of agent threads to be created (i.e. number of parallel threads)
        self.numThread = numThread

        # specify if the threads are kept alive if there is no data to process
        self.keepAlive = keepAlive

    # specify the RDM interface mode 
    def setRDMInterfaceMode(self, mode):
        self.algorithm.rdm_imode = mode 

    # specify the destination RDM collection namespace
    def setRDMCollectionNamespace(self, namespace):
        self.algorithm.rdm_coll_ns = namespace

    # specify the destination RDM dir relative to the collection namespace
    def setRDMDatadirRelative(self, dir):
        self.algorithm.rdm_datadir_rel = dir

    # specify the configuration file to underlying algorithm
    def setConfig(self, path):
        self.algorithm.config = path

    # add new study on demand
    def addStudy(self, study):
        self.addDataItem(study)

if __name__ == "__main__":

    parg = ArgumentParser(description='get data archive of a study from Orthac PACS server')

    ## positional arguments
    parg.add_argument('id',
                      metavar = 'id',
                      nargs   = '+',
                      help    = 'Orthanc ID of a study')

    ## optional arguments
    parg.add_argument('--host_pacs',
                      action  = 'store',
                      dest    = 'host_pacs',
                      default = 'pl-torque.dccn.nl',
                      help    = 'specify the host of the Orthanc PACS server')

    parg.add_argument('--port_pacs',
                      action  = 'store',
                      dest    = 'port_pacs',
                      default = 8042,
                      help    = 'specify the port of the Orthanc PACS server')

    parg.add_argument('--rdm_imode',
                      action  = 'store',
                      dest    = 'rdm_imode',
                      choices = ['icommands','restful'],
                      default = 'icommands',
                      help    = 'specify the iRODS client interface for RDM')

    parg.add_argument('--rdm_coll_ns',
                      action  = 'store',
                      dest    = 'rdm_coll_ns',
                      default = '/rdm-tst/di/dccn/dac_t00001',
                      help    = 'specify the destination RDM collection namespace, e.g. /rdm-tst/di/dccn/dac_t00001')

    parg.add_argument('--rdm_datadir_rel',
                      action  = 'store',
                      dest    = 'rdm_datadir_rel',
                      default = 'raw',
                      help    = 'specify the destination data directory relative to the RDM collection namespace, e.g. ./raw')

    parg.add_argument('--config',
                      action = 'store',
                      dest   = 'config',
                      default = os.path.dirname(os.path.abspath(__file__)) + '/../etc/config.ini',
                      help   = 'specify the configuration file (see etc/config.ini as example)')

    args = parg.parse_args()

    logger = getLogger(name=os.path.basename(__file__), lvl=3)

    o = IOrthanc(host=args.host_pacs, port=args.port_pacs)

    logger.debug('downloading archive of %d study(ies) ...' % len(args.id))

    # retrieve study object based on ID
    studies = []
    for id in args.id:
        s = o.__getStudyMetadata__('/studies/%s' % id)
        if not s:
            logger.warning('study id %s not valid or not available' % id)
        else:
            studies.append(s)

    # streaming data in parallel
    runner = DataStreamer(numThread=1, keepAlive=False, studies=studies)
    runner.setLogLevel(lvl=3)
    runner.setConfig(args.config)
    runner.setRDMInterfaceMode(args.rdm_imode)
    runner.setRDMCollectionNamespace(args.rdm_coll_ns)
    runner.setRDMDatadirRelative(args.rdm_datadir_rel)
    runner.start()

    # wait until all data streaming processes are finished
    runner.join()

    # retrieve profile as MTRunner result
    profile = runner.getResults()

    # check if everything is ok
    for s in studies:
        if s not in runner.doneList:
            logger.warning('streaming of study %s not completed properly' % s.ID)
            print >>sys.stderr, '%d|%s|%s' % (0, s.ID, '')
        else:
            logger.debug('streamed study %s' % s.ID)
            print '%d|%s|%s' % (1, s.ID, repr(profile[s.ID]))
