#!/usr/bin/env bash
set -euo pipefail
cd $(dirname $0)

# 20210202 init MVM

test ! -d ../group && mkdir $_

#3dMVM -prefix ../group/mvm-faceCar.nii.gz -jobs 3 \
# -bsVars 'age*cohort+sex+fsiq' \
# -wsVars 'age,fsiq' \
# -qVars 'age,fsiq' \
# -num_glt 4 \
# -gltLabel 1 Cohort_a-c    -gltCode 1 'cohort: -1*CONTROL +1*AUTISM' \
# -gltLabel 2 AgeCohort_a-c -gltCode 2 'cohort: -1*CONTROL +1*AUTISM age : ' \
# -gltLabel 3 IQCohort_a-c  -gltCode 3 'cohort: -1*CONTROL +1*AUTISM fsiq : ' \
# -gltLabel 4 Cohort_avg    -gltCode 4 'cohort: .5*CONTROL +.5*AUTISM' \
# -dataTable @txt/mvm-faceCar.tsv

# original 2015 MVM used -wsVars 'stim*task' \
# b/c decon had task (cond1 and cond2) as well as stim (USA, AUS, Cars)
# in this pass, stim was combined in the decon and
# we haven't looked at cond2 (testC), only cond1 (MemC)
3dMVM -prefix ../group/mvm-faceCar.nii.gz -jobs 3 \
 -bsVars 'age*cohort' \
 -qVars 'age' \
 -num_glt 2 \
 -gltLabel 1 Cohort_a-c    -gltCode 1 'cohort: -1*CONTROL +1*AUTISM' \
 -gltLabel 2 AgeCohort_a-c -gltCode 2 'cohort: -1*CONTROL +1*AUTISM age : ' \
 -dataTable @txt/mvm-faceCar.tsv
