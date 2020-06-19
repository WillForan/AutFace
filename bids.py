#!/usr/bin/env python
import pandas as pd

LOOKUP = pd.read_csv("txt/mr_task.txt", sep=" ")
# get just unique mrid->id and make a dictionary
IDLOOKUP = LOOKUP.groupby('mrid').agg({'id': 'mean'}).to_dict()['id']
# make strings
IDLOOKUP = {str(k): str(v) for k,v in IDLOOKUP.items()}


def create_key(template, outtype=('nii.gz','json'), annotation_classes=None):
    return (template, outtype, annotation_classes)


def infotoids(seqsinfo, outdir):
    """lookup subject using patname and info sheet"""
    allids = [x.patient_id for x in seqsinfo]
    # TODO: check all patient_ids are the same
    s = allids[0]

    return({'subject': "sub-" + IDLOOKUP.get(s, 'UNKNOWN'),
            'locator': None, 'session': None})


def infotodict(seqinfo):

    bids_keys = {
      't1w': create_key('anat/{subject}_T1w'),
      'rest': create_key('func/{subject}_task-rest_bold'),

      # these names are created by merge_times.R
      'AUS': create_key('func/{subject}_task-AUS_run-{item:02d}_bold'),
      'USA': create_key('func/{subject}_task-USA_run-{item:02d}_bold'),
      'Cars': create_key('func/{subject}_task-Cars_run-{item:02d}_bold'),
      'AUSTest': create_key('func/{subject}_task-AUSTest_run-{item:02d}_bold'),
      'USATest': create_key('func/{subject}_task-USATest_run-{item:02d}_bold'),
      'CarsTest': create_key('func/{subject}_task-CarsTest_run-{item:02d}_bold')
    }

    info = {x: [] for x in bids_keys.values()}
    for s in seqinfo:
        # want the dict like {create_key: [series_id(s)]}
        # SeqInfo(total_files_till_now=3, example_dcm_file='001-0001-00001-0.dcm',
        #  series_id='1-circle_localizer', dcm_dir_name='001', series_files=3, unspecified='',
        #  dim1=256, dim2=256, dim3=3, dim4=1, TR=0.02, TE=3.39, protocol_name='circle_localizer',
        #  is_motion_corrected=False, is_derived=False, patient_id='110308160921',
        #  study_description='Dr. Luna^routine', referring_physician_name='', series_description='Circle Scout',
        #  sequence_name='fl2d1', image_type=('ORIGINAL', 'PRIMARY', 'M', 'ND'),
        #  accession_number='', patient_age='xxY', patient_sex='X', date='20110308',
        #  series_uid='1.3.12.2.1107.5.2.7.20411.30000011030816023353100000011')
        query="seqnum==%d & mrid==%s"%(int(s.dcm_dir_name), s.patient_id)
        match = LOOKUP.query(query)
        if len(match)==1:
           tname=match['tname'].to_list()[0]
           info[bids_keys[tname]].append(s.series_id)
        elif s.dim4 == 1  and s.protocol_name in "TC_t1_mprage_sag_ns":
           info[bids_keys['t1w']] = [s.series_id]
        elif s.dim4 == 200 and s.protocol_name in "ep2d_bold_rest":
           info[bids_keys['rest']].append(s.series_id)
        else:
           print("# no match! " + s.protocol_name)
           continue

    print(info)
    return info
