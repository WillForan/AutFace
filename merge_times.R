#!/usr/bin/env Rscript
library(dplyr)
library(lubridate)

# create datetime and rank task order within visits
# for both mr and task
mr <- read.table('txt/times_mr.txt')  %>%
    `names<-`(c('mrid','seqnum','dim4','task','time','age','sex')) %>%
    mutate(dt=ymd_hms(paste0("20",substr(mrid,0,6)," ", time))) %>%
    group_by(mrid) %>%
    filter(grepl('ep2d_bold_face',task), dim4 %in% c(188, 226, 228)) %>%
    mutate(rank=rank(seqnum), start=min(dt))

tk <- read.table('txt/times_task.txt') %>%
    `names<-`(c('id','year','task','day','time')) %>%
    mutate(dt=mdy_hms(paste0(day," ", time))) %>%
    group_by(id,year) %>%
    mutate(rank=rank(dt), start=min(dt))

tk1 <- tk %>% filter(rank==1) %>% select(id, year, start)
mr1 <- mr %>% filter(rank==1) %>% select(mrid, start)
mrtk <-
    # all-to-all merge
    merge(mr1, tk1, by=c(), suffixes=c('_mr','_tk')) %>%
    group_by(mrid) %>% 
    mutate(start_diff=as.numeric(abs(start_tk - start_mr)/60)) %>%
    filter(start_diff==min(start_diff)) %>%
    select(mrid, id, year, start_diff, start_mr, start_tk)
write.table(mrtk, 'txt/mrid_id.txt', row.names=F, quote=F)

all_mrtk <-
    mrtk %>%
    select(-matches('start')) %>%
    merge(mr %>% select(mrid, seqnum, rank)) %>%
    merge(tk %>% select(id, year, task, rank)) %>%
    mutate(tname=gsub('^CMFT','USA', task) %>% gsub('_CMFT','',.) %>% gsub('_Cond2','Test',.))
write.table(all_mrtk, 'txt/mr_task.txt', row.names=F, quote=F)
