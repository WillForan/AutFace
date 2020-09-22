# 
# WF20150317  -- contrast asd/td face and cars
#  see AL's version: 
#  ../3dMVM/scripts/3dMVM_FacesvCars_test_2_rmbehoutliers.sh
#
# need datatable  from demog.txt (from 00_getData.R)
#
# Within subj : cars,faces(usa+aus)
# Between subj: ASD vs TD
# ---
# BTC says 
#  stim:.66 Cars - .33AUS -.33USA
#  diagnosis: .5ADS - .5TD

scriptdir=$(cd $(dirname $0);pwd)
contrast="mem_face"


# build datatable for 3dMVM
cut -f1,8- txt/demog.txt|while read id allother; do 
 # if first line add "InputFile"
 [[ $id == "Subj" ]] && echo "$id	$allother	task	stim	InputFile" && continue

 # do we have all 3 for this subj
 !  ls $scriptdir/glm/Y1_Center/$id/*{usa,aus,cars}*stats+tlrc.HEAD 2>/dev/null 1>&2 &&
  echo "missing usa aus or cars for $id" >&2 && continue

 #find the file we want to use as input
 for stim in usa aus cars; do
   echo "$id	$allother	memC	$stim	$(ls $scriptdir/glm/Y1_Center/$id/*$stim*stats+tlrc.HEAD)[memC#0_Coef]"
   echo "$id	$allother	testC	$stim	$(ls $scriptdir/glm/Y1_Center/$id/*$stim*stats+tlrc.HEAD)[testC#0_Coef]"
 done

done> txt/demog_${contrast}.txt

[ ! -d 3dMVM ] && mkdir 3dMVM

stimeq=' stim : .33*usa +.33*aus -.66*cars'

3dMVM -prefix 3dMVM/$contrast \
  -model 'diagg*ageg' \
  -wsVars 'stim*task' \
  -gltLabel  1 'M_faceMcars'  -gltCode  1 "task : 1*memC  $stimeq                                     " \
  -gltLabel  2 'M_FMC_ASD'    -gltCode  2 "task : 1*memC  diagg : 1*ASD         $stimeq               " \
  -gltLabel  3 'M_FMC_TD'     -gltCode  3 "task : 1*memC  diagg : 1*TD          $stimeq               " \
  -gltLabel  4 'M_FMC_TDmASD' -gltCode  4 "task : 1*memC  diagg : .5*TD -.5*ASD $stimeq               " \
  -gltLabel  5 'M_cars'       -gltCode  5 'task : 1*memC                        stim : 1*cars         ' \
  -gltLabel  6 'M_faces'      -gltCode  6 'task : 1*memC                        stim : .5*usa +.5*aus ' \
  -gltLabel  7 'T_faceMcars'  -gltCode  7 "task : 1*testC $stimeq                                     " \
  -gltLabel  8 'T_FMC_ASD'    -gltCode  8 "task : 1*testC diagg : 1*ASD         $stimeq               " \
  -gltLabel  9 'T_FMC_TD'     -gltCode  9 "task : 1*testC diagg : 1*TD          $stimeq               " \
  -gltLabel 10 'T_FMC_TDmASD' -gltCode 10 "task : 1*testC diagg : .5*TD -.5*ASD $stimeq               " \
  -gltLabel 11 'T_cars'       -gltCode 11 'task : 1*testC                       stim : 1*cars         ' \
  -gltLabel 12 'T_faces'      -gltCode 12 'task : 1*testC                       stim : .5*usa +.5*aus ' \
  -gltLabel 13 'MmT_faces'    -gltCode 13 'task : .5*memC -.5*testC stim : .5*usa +.5*aus ' \
  -num_glt  13 \
  -mask /Volumes/TX/Autism_Faces/connect/mask/allctg/group_mask_intersection+tlrc.BRIK \
  -jobs 8 \
  -dataTable $(cat txt/demog_${contrast}.txt)
