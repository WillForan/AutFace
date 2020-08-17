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


## TODO
* datalad
* `bids.py` - confirm `sdim4` uniquely IDs which task (USA, AUS, CARS, rest)
  * json side card is where?
  * see https://nipype.readthedocs.io/en/latest/api/generated/nipype.interfaces.dcm2nii.html
* compare generated mrid<->id pairs to previous iterations
* extract event timing from eprime log files
* preprocess
* deconvolve/PPI
