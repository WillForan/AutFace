#!/usr/bin/env Rscript 
task <- read.csv('txt/onsets_recall.csv')
num_correct <- task %>%
    filter(event=="TestSlide") %>%
    group_by(id, year) %>%
    summarise(task_recalled=sum(TestSlide.ACC), task_forgot=sum(TestSlide.ACC==0), tasks_runs=length(unique(task)))

write.csv(num_correct, 'txt/task_score.csv', row.names=F)
