#!/usr/bin/env R

# 20210114WF - init
# pull WFU (CW, RB) Network Analysis
# subset columns, merge ID, add behavior

library(dplyr)
ids <- read.table('txt/mrid_id.txt', h=T)
net <- read.csv('txt/AUT_NetworkAnalysis_0.5000.csv')
num_correct <- read.csv('txt/task_score.csv')
# roi timepoints are all 188, as are timecorse_timepoints
# roi_noes == 116
net_quick <- net %>% select(mrid=MR.ID, roi_nodes, roi_atlas,
                            charpath_lambda, charpath_ecc_std,
                            efficiency_local_mean,
                            smallworld_value)  %>%
    left_join(ids %>% select(mrid, id, year), by="mrid") %>%
    left_join(num_correct, by=c("id","year"))

write.csv(net_quick, 'txt/AUT_Net_0.5_OHID_quick.csv')
head(net_quick)
