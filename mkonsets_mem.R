#!/usr/bin/env Rscript
library(magrittr)
library(dplyr)
library(tidyr)

## TASK EVENT ORDER
# Fix1
# memL -> 3000
# memC -> 3000
# memR -> 3000
# Fix2
# TestL-> 4500
# Fix3
# TestC-> 4500
# Fix4
# TestR-> 4500

## IN->Out
# IN: ../txt/eprime/AUS_CMFT.tsv
#  year  id     task SessionDate  Fix1 Fix2 Fix3 Fix4 TestC.ACC TestL.ACC
#     1 123 AUS_CMFT  2011-08-03 15000 7500 3000 1500         1         1
#     1 123 AUS_CMFT  2011-08-03  1500 7500 6000 4500         1         1
#  TestR.ACC TestC.RT TestL.RT TestR.RT
#          1     1611     1442     1688
#          1     1724     1211     1780

# OUT:   txt/all_onsets.csv
# year  id     task            tasktime repnum event ACC   dur   RT onset
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  Fix1  NA 15000   NA   0.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  MemL  NA  3000   NA  15.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  MemC  NA  3000   NA  18.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  MemR  NA  3000   NA  21.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  Fix2  NA  7500   NA  24.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1 TestL   1  4500 1729  31.5


## finally timing
# 
# > onsets_forced %>% filter(event=="TestR", repnum==6) %>% group_by(year,task,onset) %>% tally %>% showdf
# year     task onset   n
#    1 AUS_CMFT 262.5  99
#    1     Cars 259.5 101
#    1     CMFT 258.0  99
#    2 AUS_CMFT 262.5  30
#    2     Cars 259.5  30
#    2     CMFT 258.0  30


# make Front=>Left, Side=>Center, and Back=>Right for Cars
# and then truncate all the names
# rename Test[LCR]*.(RT|Acc) to remove whatever is in the *
rename_events <- function(x)
    gsub("Fixation","Fix", x) %>%
    gsub("Front", "Left", .) %>%
    gsub("Side", "Center", .) %>%
    gsub("Back", "Right", .) %>%
    gsub("(L|R|C).*\\.","\\1.",.) %>%
    gsub("orize|ation|eft|enter|ight", "", .)


# read in and
# * merge SessionTime
# * populate SessionDate where missing
# * make pilot path look like year 1 path
# * strip off -id-year.txt from
# * get year and task from "file"
all_tasklogs <-
    Sys.glob("txt/eprime/[AC]*tsv") %>%
    lapply(function(f) {
        x <- read.table(f, sep="\t", header=T)
        names(x) <- rename_events(names(x))
        return(x)
    }) %>%
    bind_rows %>%
    mutate(file=gsub("../task/Pilot Subs/([0-9]+)_(KOH|LR)/","1/\\1/",file) %>%
                gsub("-.*.txt", "", .)) %>%
    separate(file,c("year","id","task"),extra="merge",remove=F) %>%
    mutate_at(vars(id,year), as.numeric)

# read in task times (`tasklog` kills line with time b/c it's all NAs otherwise)
# output from mktime_task
tasktimes <-
    read.table("txt/times_task.txt") %>%
    `names<-`(c("id","year","task","SessionDate","SessionTime"))

# Combine SessionDate and SessionTime into R datatime
d <- left_join(all_tasklogs, tasktimes) %>%
    group_by(file) %>%
    mutate(SessionDate=first(na.omit(SessionDate)),
           tasktime=first(na.omit(SessionTime)) %>%
               ifelse(is.na(.), "00:00:00", .) %>%
               paste(SessionDate, .) %>%
               lubridate::mdy_hms()) %>%
    ungroup()

## make a "duration" dataframe also includes ACC and RT
#  count reps of the Fix-Mem-(Fix-Test)x3 pattern
mem_dur <- 3000
test_dur <- 4500
durs <- d %>%
    select(year,id,task,tasktime,matches("Fix[0-9]$|RT$|\\.ACC$")) %>%
    mutate_at(vars(matches("ACC")), function(x) ifelse(is.na(x), 0, x))%>%
    group_by(year,id,task,tasktime) %>%
    # each sequence happens 6 times
    # add durations for each side (mem_dur and test_dur)
    mutate(repnum=1:n(),
           MemL=mem_dur, MemC=mem_dur, MemR=mem_dur,
           TestL=test_dur, TestC=test_dur, TestR=test_dur) 

# use factor to enforce task order
eventorder=c('Fix1' ,'MemL' ,'MemC' ,'MemR',
             'Fix2', 'TestL',
             'Fix3', 'TestC',
             'Fix4', 'TestR')

# expand durations by reshaping
#  from many columns to many rows. add column to type RT,ACC, and dur (empty)
#  put back type rows into columns matched on event
#  calculate onset from durations
onsets_forced <-
    durs %>% ungroup %>%
    # Fix1-3, MemL,C,R and TestL,C,R all into rows per id+session+rep
    gather("event", "dur", -id, -year, -task, -tasktime, -repnum) %>%
    # pull out eg. TestL.Acc from 1 col into to cols: e.g. event=TestL, x=Acc
    separate(event, c("event","x"), fill="right") %>%
    mutate(
      # put into the correct order
      event=factor(event, levels=eventorder),
      # memL and testL (not e.g. testL.Acc) splits into x==NA
      # but this is duration
      x=ifelse(is.na(x), "dur", x)) %>%
    # 3 columns per fevent "dur", "RT", and "ACC"
    spread(x, dur) %>%
    # get onsets fromd durations (make sure everything is in order first)
    arrange(id, year, tasktime, task, repnum, event) %>%
    group_by(id, year, tasktime, task) %>%
    mutate(onset=round(cumsum(lag(dur, default=0))/1000,1))

write.csv(onsets_forced, "txt/onsets_mem.csv")
# looks like:
# year  id     task            tasktime repnum event ACC   dur   RT onset
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  Fix1  NA 15000   NA   0.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  MemL  NA  3000   NA  15.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  MemC  NA  3000   NA  18.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  MemR  NA  3000   NA  21.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  Fix2  NA  7500   NA  24.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1 TestL   1  4500 1729  31.5
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  Fix3  NA  3000   NA  36.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1 TestC   1  4500 2528  39.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1  Fix4  NA  1500   NA  43.5
#    1 102 AUS_CMFT 2011-10-01 12:23:14      1 TestR   1  4500 1868  45.0
#    1 102 AUS_CMFT 2011-10-01 12:23:14      2  Fix1  NA  1500   NA  49.5
