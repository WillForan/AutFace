.PHONY: all always
all: txt/mr_task.txt

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
