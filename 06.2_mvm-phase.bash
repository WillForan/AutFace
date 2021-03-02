#!/usr/bin/env bash
set -euo pipefail
cd $(dirname $0)

# 20210301 MVM of all the phases

test ! -d ../group && mkdir $_

# 2) absence of the quantitative covariate in the GLT => test @ center value
# 3) The effect for a quantitative variable (or slope) can be specified
#    by omitting the value after the colon. For example,
#    'Group : 1*Old Age : ', or
#    'Group : 1*Old - 1*Young Age : '.
# 4) The absence of a categorical =>  levels are averaged (or collapsed)
njobs=$[$(nproc --all)/2]

          age='age :'
  cohort_diff='cohort : -1*CONTROL +1*AUTISM'
 mem_face_car='phase : -1*Cmem +.5*Amem +.5*Umem'
corr_face_car='phase : -2*Ccorr +1*Acorr +1*Ucorr'
 corr_aus_usa='phase : -1*Acorr +1*Ucorr'
  mem_aus_usa='phase : -1*Amem +1*Umem'
   A_mem_corr='phase : -1*Amem +1*Acorr'
   C_mem_corr='phase : -1*Cmem +1*Ccorr'
   U_mem_corr='phase : -1*Umem +1*Ucorr'
   F_mem_corr='phase : -1*Umem -1*Amem +1*Ucorr +1*Acorr'

3dMVM -prefix ../group/mvm-cond1-phase.nii.gz -jobs $njobs \
 -bsVars 'age*cohort' \
 -wsVars 'phase'  \
 -qVars 'age' \
 -num_glt 26 \
 -gltLabel 1 Corr_f-c           -gltCode 1  "$corr_face_car" \
 -gltLabel 2 Corr_u-a           -gltCode 2  "$corr_aus_usa" \
 -gltLabel 3 Mem_f-c            -gltCode 3  "$mem_face_car" \
 -gltLabel 4 Mem_u-a            -gltCode 4  "$mem_aus_usa" \
 -gltLabel 5 AUS_c-m            -gltCode 5  "$A_mem_corr" \
 -gltLabel 6 USA_c-m            -gltCode 6  "$U_mem_corr" \
 -gltLabel 7 CAR_c-m            -gltCode 7  "$C_mem_corr" \
 -gltLabel 8 FACE_c-m           -gltCode 8  "$F_mem_corr" \
 -gltLabel 9 Cohort_a-c         -gltCode 9  "$cohort_diff" \
 \
 -gltLabel 10 CohortCorr_f-c    -gltCode 10 "$cohort_diff $corr_face_car" \
 -gltLabel 11 CohortCorr_u-a    -gltCode 11 "$cohort_diff $corr_aus_usa" \
 -gltLabel 12 CohortMem_f-c     -gltCode 12 "$cohort_diff $mem_face_car" \
 -gltLabel 13 CohortMem_u-a     -gltCode 13 "$cohort_diff $mem_aus_usa" \
 -gltLabel 14 CohortAUS_c-m     -gltCode 14 "$cohort_diff $A_mem_corr" \
 -gltLabel 15 CohortUSA_c-m     -gltCode 15 "$cohort_diff $U_mem_corr" \
 -gltLabel 16 CohortCAR_c-m     -gltCode 16 "$cohort_diff $C_mem_corr" \
 -gltLabel 17 CohortFACE_c-m    -gltCode 17 "$cohort_diff $F_mem_corr" \
 \
 -gltLabel 18 AgeCohort_a-c     -gltCode 18 "$cohort_diff $age" \
 -gltLabel 19 AgeCohortCorr_f-c -gltCode 19 "$cohort_diff $corr_face_car $age" \
 -gltLabel 20 AgeCohortCorr_u-a -gltCode 20 "$cohort_diff $corr_aus_usa $age" \
 -gltLabel 21 AgeCohortMem_f-c  -gltCode 21 "$cohort_diff $mem_face_car $age" \
 -gltLabel 22 AgeCohortMem_u-a  -gltCode 22 "$cohort_diff $mem_aus_usa $age" \
 -gltLabel 23 AgeCohortAUS_c-m  -gltCode 23 "$cohort_diff $A_mem_corr $age" \
 -gltLabel 24 AgeCohortUSA_c-m  -gltCode 24 "$cohort_diff $U_mem_corr $age" \
 -gltLabel 25 AgeCohortCAR_c-m  -gltCode 25 "$cohort_diff $C_mem_corr $age" \
 -gltLabel 26 AgeCohortFACE_c-m -gltCode 26 "$cohort_diff $F_mem_corr $age" \
 -dataTable @txt/mvm-phase_ses-1.tsv
