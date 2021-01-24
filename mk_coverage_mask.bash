#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

#
# 20210124WF - coverage mask of all subjects

3dMean -prefix masks/memtask_coverage.nii.gz -count ../preproc/{aus,cars,usa}/*/ses-*/*/subject_mask.nii.gz
3dcalc -prefix masks/memtask_coverageGT200.nii.gz -a masks/memtask_coverage.nii.gz -expr 'step(a-200)'

