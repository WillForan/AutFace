#!/usr/bin/env Rscript
# 20210202 WF -- copy out of merge_box.R for generic saving

# only have six sig figs for bircid in 2018 demog csv
id6 <- function(id) substr(as.character(id),1,6)

ids <- read.table('txt/mrid_id.txt', h=T)  %>%
    select(mrid, id) %>%
    mutate(truncid=id6(mrid))
dmg <- read.csv('txt/AutSubDemos_20180501.csv') %>%
    mutate(truncid=id6(bircid/10)) %>% select(-age.x) %>% rename(age=age.y)
task <- read.csv('txt/task_score.csv')
fd_smry <- read.csv('txt/fd_summary.csv') %>% group_by(Subj,ses) %>%
    summarise(fd_task_mean=mean(mean),
              fd_task_ngt.8=sum(nhigh))
id_dmg <- ids %>% full_join(dmg, by=c("truncid", "id"="ohid"))  %>%
    select(-truncid, bircid) %>%
    full_join(task, by=c("id"="id", "timepoint"="year")) %>%
    full_join(fd_smry, by=c("id"="Subj", "timepoint"="ses"))

# dob is from OHearnDatabase. which doesn't not overlap well
#dob <- read.csv('txt/dob.csv')
#%>% full_join(dob, by="id")

# 13 that I don't have MR data for!
# id_dmg %>% filter(is.na(mrid))

id_dmg <- id_dmg %>% filter(!is.na(mrid)) %>% select(-bircid)

write.csv(id_dmg, 'txt/id_dmg.csv', row.names=F)
