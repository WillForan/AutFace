
## Fixation1 onsettime is start of task
# 37 without "Onset" timings, 90 w/it -- use only for confirmation
onsets <- d %>%
    select(year,id,task,SessionDate,matches("Onset")) %>%
    gather("event","onset_raw", -year,-id,-task, -SessionDate) %>%
    mutate(event=gsub(".OnsetTime$","",event)) %>% 
    arrange(id, onset_raw) %>% filter(!is.na(onset_raw)) %>% 
    group_by(id,year,SessionDate) %>%
    mutate(
        # normlize by first onset time. round to 1/10ths
        onset=round((onset_raw-first(onset_raw))/1000, 1),
        # calc duration from onsets
        dur=lead(onset)-onset,
        # shorten event names. make Cars match AUS/Face
        event=rename_events(event)) %>%
    group_by(id,year,SessionDate,event) %>%
    mutate(repnum=1:n())

#  year  id     task SessionDate event onset_raw onset  dur
#     1 125 AUS_CMFT  01-07-2012 Fix1      40734   0.0 15.0
#     1 125 AUS_CMFT  01-07-2012 MemL      55729  15.0  3.0
#     1 125 AUS_CMFT  01-07-2012 MemC      58738  18.0  3.0
#     1 125 AUS_CMFT  01-07-2012 MemR      61730  21.0  3.0
#     1 125 AUS_CMFT  01-07-2012 Fix2      64739  24.0  7.5
#     1 125 AUS_CMFT  01-07-2012 TestL     72228  31.5  4.5
#     1 125 AUS_CMFT  01-07-2012 Fix3      76725  36.0  3.0
#     1 125 AUS_CMFT  01-07-2012 TestC     79734  39.0  4.5
#     1 125 AUS_CMFT  01-07-2012 Fix4      84231  43.5  1.5
#     1 125 AUS_CMFT  01-07-2012 TestR     85736  45.0  4.5
#     1 125 AUS_CMFT  01-07-2012 Fix1      90232  49.5  1.5
#     1 125 AUS_CMFT  01-07-2012 MemL      91737  51.0  3.0
#     1 125 AUS_CMFT  01-07-2012 MemC      94729  54.0  3.0
#     1 125 AUS_CMFT  01-07-2012 MemR      97738  57.0  3.0
#     1 125 AUS_CMFT  01-07-2012 Fix2     100731  60.0  7.5
#     1 125 AUS_CMFT  01-07-2012 TestL    108237  67.5  4.5

allon <- inner_join(onsets, onsets_forced, by=c("year","id","task","event", "repnum"))
