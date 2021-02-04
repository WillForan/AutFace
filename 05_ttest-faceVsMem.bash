#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
env|grep -q ^DRYRUN=. && DRYRUN=echo || DRYRUN=

# run ttest on face-car contrast
# see 05_mkttest_in.R for   -> txt/dt/glm_faceVcar.txt
#     mk_coverage_mask.bash -> masks/memtask_coverageGT200.nii.gz
# (also annotate in Makefile)
#
# 20210124WF - init
getset(){
   perl -slane 'print "$F[0] $F[1]","[corr-mem_GLT#0_Coef]" if m/$pat/' -- -pat="$1" < txt/dt/glm_faceVcar.txt
}

# TODO: age and iq covariets
$DRYRUN 3dttest++ \
   -prefix ../stats/face-mem_ttest.nii.gz \
   -Clustsim 4 \
   -mask masks/memtask_coverageGT200.nii.gz \
   -setA ASD $(getset 'ASD$') \
   -setB TD $(getset 'TD$')   \
