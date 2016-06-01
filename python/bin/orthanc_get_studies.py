#!/usr/bin/env python
import os
import sys
import re
import argparse
from datetime import date, datetime, timedelta
sys.path.append('%s/external' % os.environ['DCCN_PYTHONDIR'])
sys.path.append('%s/lib' % os.environ['DCCN_PYTHONDIR'])
from orthanc.IOrthanc import IOrthanc
from common.Utils import makeTabular

# helper functions
def show_studies(studies):
    """ show studies in a nice-looking table
    :param studies: a list of OrthancDicomMetadata objects, each contains metadata of a DICOM study
    :return:
    """

    t_keys = ['ID','Description','Date Time','Patient']
    d_keys = ['id','desc','time','patient']

    data = []
    for s in studies:
        data.append( {'id'     : s.ID,
                      'desc'   : s.MainDicomTags.StudyDescription,
                      'time'   : '%s %s' % (s.MainDicomTags.StudyDate, s.MainDicomTags.StudyTime.split('.')[0]),
                      'patient': s.ParentPatientName})

    t = makeTabular('', data, d_keys, t_keys, '\n')
    print(t.table.encode('utf-8'))

def list_studies(studies):
    """ list ids of studies
    :param studies: a list of OrthancDicomMetadata objects, each contains metadata of a DICOM study
    :return:
    """

    for s in studies:
        print(s.ID)

def download_studies(iorthanc, studies, basedir, show_progress=False, mk_checksum=False):
    """ download archives for DICOM studies
    :param iorthanc: the IOrthanc interface object
    :param studies: a list of OrthancDicomMetadata objects, each contains metadata of a DICOM study
    :param basedir: the basedir in which the downloaded archive (.zip) files to be stored
    :param show_progress: show the progress bar of the download process
    :param do_checksum: calculate checksums of the files in the downloaded archive, and store the checksum as
                        a text file in the same archive
    :return:
    """

    print('%d studies to download' % len(studies))
    for s in studies:
        rsrc_path = 'studies/%s' % s.ID
        dest_fpath = os.path.join(basedir, '%s_%s_%s.zip' % (s.MainDicomTags.StudyDescription, s.MainDicomTags.StudyDate, s.MainDicomTags.StudyTime.split('.')[0]))

        print('downloading study %s ...' % dest_fpath)
        iorthanc.getArchive(rsrc_path, dest_fpath, progress=show_progress, checksum=mk_checksum)

# execute the main program
if __name__ == "__main__":

    # command-line argument validators
    def valid_path(s):
        if os.path.isfile(s):
            return s
        else:
            msg = "Invalid filesystem path: %s" % s
            raise argparse.ArgumentTypeError(msg)

    def valid_dir(s):
        if os.path.isdir(s):
            return s
        else:
            msg = "Invalid filesystem directory: %s" % s
            raise argparse.ArgumentTypeError(msg)

    def valid_datetime(s):
        if not s:
            return datetime.now()

        try:
            return datetime.strptime(s, "%Y-%m-%d %H:%M:%S")
        except ValueError:
            msg = "Not a valid date: '{0}'.".format(s)
            raise argparse.ArgumentTypeError(msg)

    valid_actions = ['show','download','list']
    def valid_action(s):
        if not s:
            return 'show'

        if s in valid_actions:
            return s
        else:
            msg = "Invalid action: %s" % s
            raise argparse.ArgumentTypeError(msg)

    # command-line argument parser
    p = argparse.ArgumentParser(description='get DICOM studies from the Orthanc PACS server', version="0.1")

    p.add_argument('action',
                   metavar = 'action',
                   type = valid_action,
                   default = 'show',
                   help = 'specify one of the valid actions: %s' % ','.join(valid_actions))

    # optional arguments
    p.add_argument('-c','--config',
                    action  = 'store',
                    dest    = 'config',
                    type    = valid_path,
                    default = '%s/config/config.ini' % os.environ['DCCN_PYTHONDIR'],
                    help    = 'specify the configuration file')

    p.add_argument('-t', '--to',
                    dest    = 'to_datetime',
                    action  = 'store',
                    type    = valid_datetime,
                    default = datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    help    = 'datetime in %%Y-%%m-%%d %%H:%%M:%%S format, e.g. 2016-01-01 00:00:00')

    p.add_argument('-f', '--from',
                    dest    = 'from_datetime',
                    action  = 'store',
                    type    = valid_datetime,
                    default = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d %H:%M:%S'),
                    help    = 'datetime in %%Y-%%m-%%d %%H:%%M:%%S format, e.g. 2015-01-01 00:00:00')

    p.add_argument('--patient-name-regex',
                   dest    = 'patient_name_regex',
                   action  = 'store',
                   type    = str,
                   default = '^.*$',
                   help    = 'specify regular expression pattern to filter studies with the DICOM PatientName')

    p.add_argument('-s', '--store',
                   dest    = 'store_dir',
                   action  = 'store',
                   type    = valid_dir,
                   default = '/scratch/data',
                   help    = 'specify the path in which the downloaded DICOM archive files are stored')

    p.add_argument('--stable-only',
                   dest    = 'stable_only',
                   action  = 'store_true',
                   default = False,
                   help    = 'set to show only the studies that are considered "stable" in Orthanc')

    args = p.parse_args()

    # Orthanc interface object
    iorthanc = IOrthanc(config=args.config)

    t_beg = args.from_datetime
    t_end = args.to_datetime

    re_patient_name = re.compile(args.patient_name_regex)

    studies = []
    for s in iorthanc.getStudies(last_update_range=[t_beg, t_end], stableOnly=args.stable_only):


        # exclude "service" scanns
        if "(null)" in [s.MainDicomTags.StudyDate, s.MainDicomTags.StudyID, s.MainDicomTags.StudyTime]:
            continue

        patient = iorthanc.__getPatientMetadata__('patients/%s' % s.ParentPatient)

        if not re_patient_name.match(patient.MainDicomTags.PatientName):
            continue

        # update study with PatientName
        s.__dict__.update({'ParentPatientName': patient.MainDicomTags.PatientName})
        studies.append(s)

    if args.action == 'show':
        show_studies(studies)
    elif args.action == 'list':
        list_studies(studies)
    elif args.action == 'download':
        download_studies(iorthanc, studies, args.store_dir)
