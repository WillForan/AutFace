library(dplyr)
id_dmg <- read.csv('txt/id_dmg.csv') # see id_demog.R
stat_files <- Sys.glob('txt/from_box/AUT_*csv') %>% grep(pattern="OHID_quick",invert=T, value=T)
all_stats <- lapply(stat_files, function(f) {
    d <- read.csv(f)
    # rename
    prefix <- gsub('AUT_|.csv','', basename(f))
    n <- names(d)
    names(d) <- ifelse(n=="Subject", n, gsub('^', paste0(prefix,":"), n))
    return(d)
})

all_stats_wide <- Reduce(x=all_stats, function(x, y) full_join(x, y, by="Subject"))
id_stats       <- right_join(id_dmg, all_stats_wide, by=c("mrid"="Subject"))

write.csv(id_stats, 'txt/id_stats_ultrawide.csv', row.names=F)
