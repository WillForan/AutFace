.PHONY: all always
all: .make/glms_memtest.ls

# 'mkls' sential list tool
# from github.com/LabNeuroCogDevel/lncdtools

txt/times_mr.txt:
	./mktime_mr
txt/times_task.txt:
	./mktime_task

txt/mrid_id.txt txt/mr_task.txt: txt/times_mr.txt txt/times_task.txt
	./merge_times.R

txt/eprime/AUS_CMFT.tsv txt/eprime/CMFT.tsv txt/eprime/Cars.tsv txt/eprime/test_AUS_CMFT.tsv txt/eprime/test_CMFT.tsv txt/eprime/test_Cars.tsv: $(wildcard ../task/*/*.txt)
	./tasklog

txt/bids_times.tsv:
	./check_times > $@

txt/onsets_mem.csv: txt/times_task.txt txt/eprime/AUS_CMFT.tsv
	./mkonsets_mem.R

txt/onsets_recall.csv: txt/eprime/test_AUS_CMFT.tsv
	./mkonsets_recall.R

.make:
	mkdir .make

.make/1dfiles.ls: txt/onsets_mem.csv  |.make
	./03_1dTiming
	mkls $@ '1d/sub*_ses-*/*.1d'

.make/bids_func.ls: | .make
	# ./01_bids
	mkls $@ '../BIDS/sub-*/ses-*/func/sub-*ses-*_bold.nii.gz'

.make/preproc.ls:  .make/bids_func.ls
	# ./02_proc
	mkls $@ '../preproc/*/*/ses-1/sub-*_bold/nfaswdktm_func_6.nii.gz'

.make/glms_memtest.ls: .make/preproc.ls .make/1dfiles.ls
	# ./04_deconGLM
	mkls $@ '../glm/*_ses*/*glm_bucket-MemTest.nii.gz'


txt/dt/glm_faceVcar.txt:
	./05_mkttest_in.R

masks/memtask_coverageGT200.nii.gz:
	./mk_coverage_mask.bash

masks/memtask_coverageGT200.nii.gz:
	./05_mkttest_in.R

../stats/face-mem_ttest.nii.gz: txt/dt/glm_faceVcar.txt masks/memtask_coverageGT200.nii.gz
	./05_ttest-faceVsMem.bash

txt/fd_summary.csv:
	./motion_info.R

txt/id_demog.csv: txt/mrid_id.txt txt/fd_summary.csv txt/AutSubDemos_20180501.csv
	./id_dmg.R

txt/mvm-faceCar.tsv: txt/id_demog.csv
	./06_mvm-table.R

../group/mvm-faceCar.nii.gz: txt/mvm-faceCar.tsv
	./06_mvm-faceCar.bash

txt/mvm-phase.tsv txt/mvm-phase_ses-1.tsv: txt/id_demog.csv
	./06.2_mvm_table-phase.R

../group/mvm-phase.nii.gz: txt/mvm-phase.tsv
	./06.2_mvm-phase.bash

txt/id_stat_ultrawide.csv: txt/id_dmg.csv
	./merge_box.R
