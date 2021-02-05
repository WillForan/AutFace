#!/usr/bin/env bash
set -euo pipefail

# 20210204WF - use afni to get roi-roi correlation matrix for each time series
# rois from mk_aal_subset_mask.bash
mask=masks/AAL3/AAL_subset7_rsfunc.nii.gz 

for f in ../preproc/rest/*/ses-*/sub-*_task-rest_bold/bgrnaswdktm_func_6.nii.gz; do
   ! [[ $f =~ sub-[0-9]+_ses-[0-9] ]] && echo "# no id in '$f'" && continue
   id=$BASH_REMATCH
   prefix=../restcorr/$id/AAL_subset7
   test -r ${prefix}.zval.1D && echo "# have $_, skipping" && continue
   test ! -d  $(dirname $prefix) && mkdir -p $_
   @ROI_Corr_Mat -ts $f -roi $mask -zval -prefix $prefix -verb
done

