#!/usr/bin/env Rscript
library(magrittr)
library(dplyr)
library(tidyr)
# copy pasted from mkonsets_mem.R
rename_events <- function(x)
    gsub("Fixation","Fix", x) %>%
    gsub("Front", "Left", .) %>%
    gsub("Side", "Center", .) %>%
    gsub("Back", "Right", .) %>%
    gsub("(L|R|C).*\\.","\\1.",.) %>%
    gsub("orize|ation|eft|enter|ight", "", .)

# TODO: confirm first fixation is only 1.5 or 3 duration!
# final onsets are variable. so probably have some variable start?
# 4.5 seconds for response (TestSlide)
#
# year onset  n  # year onset  n 
#    1 286.6 62  #    2 286.6 23
#    1 286.7  2  #    2 286.7  7
#    1 289.5 62  #    2 289.5 29
#    1 291.0 62  #    2 291.0 30


# input from ./tasklog like
#                  file year  id           task SessionDate SessionTime FixTime
#  1/123/AUS_CMFT_Cond2    1 123 AUS_CMFT_Cond2  03-08-2011    16:50:24    1500
#  1/123/AUS_CMFT_Cond2    1 123 AUS_CMFT_Cond2  03-08-2011        <NA>    7500
#  Fix.OnsetTime CorrectResp         TestSlide TestSlide.OnsetTime TestSlide.RESP
#             NA           2   NovelHLFA040_T1                  NA              2
#  TestSlide.CRESP TestSlide.RT TestSlide.ACC            tasktime trial
#                2         2874             1 2011-03-08 16:50:24     1
#                4         2265             1 2011-03-08 16:50:24     2
#
#
# output like
# year  id           task            tasktime         TestSlide TestSlide.RT
#    1 102 AUS_CMFT_Cond2 2011-10-01 12:28:56   NovelHLFA040_T1           NA
#    1 102 AUS_CMFT_Cond2 2011-10-01 12:28:56   NovelHLFA040_T1           NA
# CorrectResp TestSlide.ACC onset
#           2             0   0.0
#           2             0   1.5

# Read in all recall tasks
tasklogs_recall <-
    Sys.glob("txt/eprime/test*tsv") %>%
    lapply(function(f) {
        x <- read.table(f, sep="\t", header=T)
        names(x) <- rename_events(names(x))
        return(x)
    }) %>%
    bind_rows %>%
    group_by(file) %>%
    mutate(
        SessionDate=first(na.omit(SessionDate)),
        tasktime=first(na.omit(SessionTime)) %>%
               ifelse(is.na(.), "00:00:00", .) %>%
               paste(SessionDate, .) %>%
               lubridate::mdy_hms(),
        trial=1:n()) %>%
    ungroup %>%
    mutate(file=gsub("../task/Pilot Subs/([0-9]+)_(KOH|LR)/","1/\\1/",file) %>%
                gsub("-.*.txt", "", .)) %>%
    separate(file,c("year","id","task"),extra="merge",remove=F) %>%
    mutate_at(vars(id,year), as.numeric)

# calc onset relative to the first fixation
# - TODO: first fixation is probably not start of scan

per_trial_col <- "^id$|year|task$|tasktime$|FixTime$|trial$|TestSlide$|CorrectResp$|ACC$|RT$"
onsets_recall <- tasklogs_recall %>%
    select(matches(per_trial_col), matches("Onset")) %>%
    mutate_at(vars(matches("ACC")), function(x) ifelse(is.na(x), 0, x)) %>%
    gather("event","onset_raw", -matches(per_trial_col) ) %>%
    mutate(event=gsub(".OnsetTime$","",event)) %>% 
    arrange(id,year,task,tasktime,trial) %>%
    group_by(id,year,task,tasktime) %>%
    mutate(
        # normlize by first onset time. round to 1/10ths
        onset=round((onset_raw-first(onset_raw))/1000, 1),
        # calc duration from onsets
        dur=lead(onset)-onset)

# hard code some timings
badidx_fix <- is.na(onsets_recall$dur) & onsets_recall$event == "Fix"
onsets_recall$dur[badidx_fix] <- onsets_recall$FixTime[badidx_fix]/1000
badidx_test <- is.na(onsets_recall$dur) & onsets_recall$event == "TestSlide"
onsets_recall$dur[badidx_test] <- 4.5
onsets_recall <- onsets_recall %>%
    mutate(onset=cumsum(lag(dur,default=29)))

out <-
   onsets_recall %>%  
   select(year,id,task,tasktime,trial,onset,event,FixTime,TestSlide,TestSlide.RT,CorrectResp,TestSlide.ACC)

write.csv(out, "txt/onsets_recall.csv", row.names=F)
