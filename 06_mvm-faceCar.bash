#!/usr/bin/env bash
set -euo pipefail
cd $(dirname $0)

# 20210202 init MVM

test ! -d ../group && mkdir $_

3dMVM -prefix ../group/mvm-faceCar.nii.gz -jobs 3 \
 -bsVars 'cohort+sex+fsiq' \
 -wsVars 'age' \
 -qVars 'age,fsiq' \
 -num_glt 4 \
 -gltLabel 1 Cohort_a-c    -gltCode 1 'cohort: -1*CONTROL +1*AUTISM' \
 -gltLabel 2 AgeCohort_a-c -gltCode 2 'cohort: -1*CONTROL +1*AUTISM age : ' \
 -gltLabel 3 IQCohort_a-c  -gltCode 3 'cohort: -1*CONTROL +1*AUTISM fsiq : ' \
 -gltLabel 4 Cohort_avg    -gltCode 4 'cohort: .5*CONTROL +.5*AUTISM' \
 -dataTable @txt/mvm-faceCar.tsv
