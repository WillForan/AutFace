#!/usr/bin/env python


def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    return (template, outtype, annotation_classes)


IDLOOKUP = {'120619161852': '3',
            '120619085225': '1',
            '120619100943': '2'}

def infotoids(seqsinfo, outdir):
    print("infotoids!")
    allids = [x.patient_id for x in seqsinfo]
    # TODO: check all patient_ids are the same
    s = allids[1]

    return({'subject': IDLOOKUP.get(s, 'UNKNOWN'),
            'locator': None, 'session': None})


def infotodict(seqinfo):

    bids_keys = {
      't1w': create_key('sub-{subject}/anat/sub-{subject}_T1w'),
      'rest': create_key('sub-{subject}/func/sub-{subject}_task-rest_bold'),
      'face': create_key('sub-{subject}/func/sub-{subject}_task-face_run-{item:02d}_bold'),
      'car': create_key('sub-{subject}/func/sub-{subject}_task-car_run-{item:02d}_bold')
    }
    bids_classify = {
      't1w':  lambda s: s.dim4 == 1   and s.protocol_name in "TC_t1_mprage_sag_ns",
      'rest': lambda s: s.dim4 == 200 and s.protocol_name in "ep2d_bold_rest",
      'face': lambda s: s.dim4 == 188 and s.protocol_name in "ep2d_bold_face",
      'car':  lambda s: s.dim4 == 266 and s.protocol_name in "ep2d_bold_car"
    }
    info = {x: [] for x in bids_keys.values()}
    for s in seqinfo:
        for k in bids_keys.keys():
            # go to next if no clasify
            if not bids_classify[k](s):
                print("# mismatch. " + s.protocol_name + " =/= " + k)
                continue

            # want the dict like {create_key: [series_id(s)]}
            ik = bids_keys[k]
            iv = s.series_id

            # only want one t1w. take last. assume it was redone for a reason
            if k == 't1w':
                info[ik] = [iv]
            else:
                info[ik].append(iv)

            # if it matches, we can be done with this `s`
            print("# found! " + s.protocol_name + " => " + k)
            break
    print(info)
    return info
