# Autism Faces
Functional MR collected from 2011-2014 with participant preforming EPrime tasks.

## Task
### memory
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
30 trials per AUS, USA, cars like Fix+Test. Resposne window is 4.5 seconds. Fixation is variable. Unclear if first fixation is known!


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


## TODO
* datalad
* `bids.py` - confirm `sdim4` uniquely IDs which task (USA, AUS, CARS, rest)
  * json side card is where?
  * see https://nipype.readthedocs.io/en/latest/api/generated/nipype.interfaces.dcm2nii.html
* compare generated mrid<->id pairs to previous iterations
* extract event timing from eprime log files
* preprocess
* deconvolve/PPI
