#!/usr/bin/env bash
set -euo pipefail
set -x

# 20210204WF - make subset mask of 7 roi pairs (bilateral)
# N.B. two sorts that need to line up
#   1. sort on grepped roi names
#   2. sort in perl on roi names
#
# if these don't line up, niether will
#  masks/AAL3/AAL_subset.nii.gz
#  masks/AAL3/AAL_subset.nii.txt
#

# what rois are we interseted in
WANT='fusiform|temporal_sup|temporal_inf|amy|frontal_inf'
label_file="masks/AAL3/orig/AAL3v1_1mm.nii.txt"
roi_file="masks/AAL3/orig/AAL3v1_1mm.nii.gz"
output="masks/AAL3/AAL_subset.nii.gz"
out_txt=${output/.gz/.txt}
# how to combine them
subset_as_3calc(){
   # output is string like:
   #  amongst(0,a-45,a-46)*1+amongst(0,a-7,a-8)*2+
   #  amongst(0,a-11,a-12)*3+amongst(0,a-10,a-9)*4+
   #  amongst(0,a-59,a-60)*5+amongst(0,a-93,a-94)*6+
   #  amongst(0,a-85,a-86)*7
   perl -slane '
   push @{$a{$F[1]}},$F[0];
   END{
   print(join "+",
              map {
                  $_="amongst(0," .
                     join(",",
                          map {$_="a-$_"}
                              @{$a{$_}}) .
                      ")*" .
                      ++$i } sort keys(%a))}'
}

grep -Pi "$WANT" $label_file |
   cut -f 1,2 -d ' '|
   sed s/_[LR]// |
   sort -k2,2 -t' ' > $out_txt
exp=$(cat $out_txt | subset_as_3calc )
3dcalc -prefix $output -a $roi_file -expr "$exp" -overwrite
3dNotes -h "$0" $output
