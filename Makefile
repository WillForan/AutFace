.PHONY: all
all: txt/mr_task.txt

txt/times_mr.txt:
	./mktime_mr
txt/times_task.txt:
	./mktime_task

txt/mrid_id.txt txt/mr_task.txt: txt/times_mr.txt txt/times_task.txt
	./merge_times.R
