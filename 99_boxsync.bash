#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
cd $(dirname $0)

#
# 20201004WF - init

[ $# -eq 0 ] && echo "$0 [scripts|bids|task|preproc] (or any combination)" && exit 1

copy="$*"

[[ "$copy" =~ scripts ]] &&
 rclone copy ./ box:Collab/KOH_Aut/scripts \
   -L --bwlimit 5M --max-size 15G -v --copy-links --size-only

[[ "$copy" =~ bids ]] &&
 rclone copy ../bids/ ../task box:Collab/KOH_Aut/BIDS \
    -L --bwlimit 5M --max-size 15G -v --copy-links --size-only

[[ "$copy" =~ task ]] &&
rclone copy ../task box:Collab/KOH_Aut/ \
   -L --bwlimit 5M --max-size 15G -v --copy-links --size-only


! [[ "$copy" =~ preproc ]] && exit 0
cat > txt/tx_filter.txt <<EOF 
+ */[12]*/ses-*/sub-*_task-*_bold/{motion_info/*,*reg*.txt,.reg*_in_use,nfaswdktm_func_6.nii.gz,motion.par,preprocessFunctional.log,tm_func.nii.gz}
+ MHT1_2mm/[12]*/ses-*/{mprage.nii.gz,mprage_bet.nii.gz,mprage_warpcoef.nii.gz,mprage_nonlinear_warp_MNI_2mm.nii.gz,mprage_warp_linear.nii.gz,preprocessMprage.log}
- *
EOF
rclone copy ../preproc/ box:Collab/KOH_Aut/preproc \
   -L --bwlimit 5M --max-size 15G -v --copy-links --size-only \
   --filter-from txt/tx_filter.txt
