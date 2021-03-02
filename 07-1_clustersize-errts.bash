#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
cd $(dirname $0)

#  20210301WF  init
# get ACF for 3dClustStim from errts
list_subj_masks(){
  perl -sle '
      print join " ",
      grep {!/Test/}  glob("../preproc/*/$1/*$2/*/subject_mask.nii.gz")
      if $exfile =~ m/(\d{3})_ses-(\d)/' -- -exfile="$1"
}

outdir=txt/acf/detrend 
test -d $outdir || mkdir -p $_
for errts in ../glm/*/*_glm_bucket-FaceVsCar_glm-10_errts.nii.gz; do
   glmdir=$(dirname $errts)
   masks=($(list_subj_masks $errts))
   subj_mask=$glmdir/subject_mask_intersection.nii.gz 
   test -r $subj_mask || 3dMean -prefix $_ -mask_inter  "${masks[@]}"
   acf_file=$outdir/$(basename $glmdir).txt
   3dFWHMx -input $errts -mask $subj_mask > $acf_file
   break
done
wait 
exit

#   sed 1d < $acf_file
## 0.721776  4.24533  15.3278    11.1196
sdir=../preproc/aus/102/ses-1/sub-102_ses-1_task-AUS_run-1_bold
3dClustSim -acf  0.721776 4.24533 15.3278  -pthr 0.05 .01 .001 -athr 0.05 -mask $sdir/subject_mask.nii.gz 
