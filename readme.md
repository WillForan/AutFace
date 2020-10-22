# Autism Faces
Functional MR collected from 2011-2014. Includes 3 sets (aus faces, usa faces, cars) of 2 (mem, recall) EPrime tasks.

[`Makefile`](./Makefile) outlines the full pipeline

## Data TX
Imaging and task data is on box.
See [`retrive_box`](retrive_box) using [rclone](https://rclone.org/box/). [`99_boxsync.bash`](99_boxsync.bash) was used to upload.

The disk usage for just the final output of preprocessing is about **115 Gb**. `124 visits * 155 Mb * 6 scans.` 

The entire preprocessing pipeline -- useful for QA, rerunning, and auditing -- is ~1Tb (`124*6*1.3G).

## Preprocessing
* `01_bids`                 - raw dcm to BIDS standard
* `021_proc_t1` + `02_proc` - [`lncdprep`](https://github.com/LabNeuroCogDevel/fmri_processing_scripts) preprocessing

### Bold

`nfaswdktm_func_6.nii.gz` is the per run MNI space T2\* image output of preprocesing.
See [`fmri_processing_Scripts`](https://github.com/LabNeuroCogDevel/fmri_processing_scripts).

The file prefix has can be read as the preprocessing steps right to left:
* `tm` - 4d slice motion
* `k` - skull strip
* `d` - wavelet despiking
* `w` - warp to mni
* `s` - susan smoothing with 6mm kernal
* `a` - `ica_aroma`
* `f` - highpass filter
* `n` - normalized timeseries to `10000/globalmedian`

Shown here with `9s Mem` event stimulus for reference (see "Timing" for more on that).
![nfaswdktm](img/102_afni_bold-aus_ideal-mem.png)

### Motion
`mt` 4dslice+motion alignment computes trans and rot motion paramaters in `motion.par` a la fsl's mcflirt. Framewise displacement is also calculated. GLM censors `fd > .8` ([`motion_info.R`](motion_info.R)).

[<img src=img/n_fd-gt-thres_hist.png width=400px>](img/n_fd-gt-thres_hist.png)


see in e.g. `../preproc/aus/102/ses-1/sub-102_ses-1_task-AUS_run-1_bold/` `motion.par` and `motion_info/*png`.


![motion](img/102_aus_motion.png)

```
1dplot -sepscl motion.par
```

### QA

* warping: inspecting all T1<->MNI linear warps as a time series -- point per visit. Okay? But 2 large ventricles participants. 
  - looking for bad skullstrip or misaligned warp.

![T1](img/QA_mprage_116.png)

## Task

### Timing
Task timing were extracted from eprime txt log files and are save as long (line/row per event) CSVs. See `mkonsets_{mem,recall}.R` on top of `tasklog` (also [`eplog`](https://github.com/LabNeuroCogDevel/lncdtools)).

* [`txt/onsets_mem.csv`](txt/onset_mem.csv) -- `"year","id","task","tasktime","repnum","event","ACC","dur","RT","onset"`
* [`txt/onsets_recall.csv`](txt/onset_recall.csv) -- `"year","id","task","tasktime","trial","onset","event","FixTime","TestSlide","TestSlide.RT","CorrectResp","TestSlide.ACC"`

The scripts `mktime_mr` and `mktime_task` are used by `merge_times.R` to match MR and Eprime run order.

### memory

![timeline](img/AUS_eprime_timeline_screenshot.png)

3 Stimulus perspectives are shown for each object. The order is always the same.
For `AUS` and `CMFT (USA)`, the order is `Left, Center, Right`; for `Cars` this is `Front, Side, Back`. When combining Left=Front, Center=Side, Right=Back.

3 (AUS, USA, Cars) versions with 6 reps of

| event | duration       |
| ----- | -------------- |
| Fix 1 | 1.5, 7.5, 15   |
| mem L | 3              |
| mem C | 3              |
| mem R | 3              |
| Fix 2 | 4.5, 7.5       |
| TestL | 4.5            |
| Fix 3 | 1.5, 3, 6, 7.5 |
| TestC | 4.5            |
| Fix 4 | 1.5, 4.5, 7.5  |
| TestR | 4.5            |

### recall
There are 30 trials per AUS, USA, cars like Fix+Test. The response window is 4.5 seconds. Fixation is variable. First fixation is 9 seconds. It's followed by 20s of review.


![9 secs fixation](img/cond2_eprime_screenshot.png)
![20 secs review](img/cond2_eprime_screenshot_20sReview.png)

3 (AUS, USA, Cars) versions with 30 reps of

| event | duration             |
| ----- | -------------------- |
| Fix   | 1.5, 3, 4.5, 6, 7.5  |
| Test  | 4.5                  |

### total times

```R
# Cond1==mem => ~ 260 secs, shorter task
# Cond2==recall=> ~300 secs, longer task 

# add 4.5 to end of all onsets (mem and recall)
> onsets_forced %>% filter(event=="TestR", repnum==6) %>% group_by(year,task,onset) %>% tally
 year     task onset   n
    1 AUS_CMFT 262.5  99
    1     Cars 259.5 101
    1     CMFT 258.0  99
    2 AUS_CMFT 262.5  30
    2     Cars 259.5  30
    2     CMFT 258.0  30

> onsets_recall %>% filter(trial==30, event=="TestSlide") %>% group_by(year, task, onset, dur) %>% tally
 year           task onset dur  n
    1 AUS_CMFT_Cond2 289.5 4.5 98
    1     Cars_Cond2 286.5 4.5 37 + 62 + 2
    1     CMFT_Cond2 291.0 4.5 99

    2 AUS_CMFT_Cond2 289.5 4.5 29
    2     Cars_Cond2 286.6 4.5 23 + 7
    2     CMFT_Cond2 291.0 4.5 30
 
```

```bash
3dinfo -nt -tr -iname ../BIDS/sub-*/ses-*/func/sub-*nii.gz|sed 's/\.\..*task-//'|sort |uniq -c
    124 188	1.5	AUS_run-1_bold.nii.gz
    126 188	1.5	Cars_run-1_bold.nii.gz
    125 188	1.5	USA_run-1_bold.nii.gz
      2 188	1.5	USATest_run-1_bold.nii.gz

    119 200	1.5	rest_bold.nii.gz

     91 226	1.5	AUSTest_run-1_bold.nii.gz
     94 226	1.5	CarsTest_run-1_bold.nii.gz
     91 226	1.5	USATest_run-1_bold.nii.gz

     32 228	1.5	AUSTest_run-1_bold.nii.gz
     32 228	1.5	CarsTest_run-1_bold.nii.gz
     32 228	1.5	USATest_run-1_bold.nii.gz
```

```bash
188*1.5 = 282 secs
200*1.4 = 300
228*1.5 = 342
226*1.5 = 339
```

## GLM

### CMFT/Cond1
* `aus`, `cars`, and `usa` (CMFT, cond1) are combined. 
* each `Mem{L,R,C}` set are treated as a single 9 secs event.
* `Test{L,R,C}` are each treated as a single type of 4.5 secs event. But are broken up by accuracy.
  * all together are also available as e.g. `1d/sub-103_ses-1/Test.1d` (c.f `1d/sub-103_ses-1/Test_{crct,err}.1d`)

The 1D files are generated with `03_1dTiming` and the models with `04_deconGLM`.

```bash
1dgrayplot ../glm/102_ses-1/X.1D
```

![Xmat](img/glm_mem-test_Xmat.png)


Motor and visual differences between `Test` and `Mem` illustrated here: 
![motor](img/glm/motor.png)
![vis](img/glm/visual.png)

## TODO
* Find ages and Diagg=="NA"
* censor previous TR to large motion? kick out high motion people?
* break up Test events by novel or not
* GLM for Cond2
* generate `errts` timeseries from 3dDeconvolve
* datalad (half implemented)
