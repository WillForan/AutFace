#!/usr/bin/env Rscript

# 20201021WF - init (in motion_info.R)
# 20210120WF - txt/demog.txt is maybe not correct!?
#              maybe should prefer txt/AutSubDemos_20180501.csv but bircids are not correct

fd_smry <- read.csv(fd_smry, 'txt/fd_summary.csv')
demog <- read.table('txt/demog.txt', header=T)
fd_smry_demog <- merge(fd_smry, demog, all.x=T, on='Subj')
    
p <- ggplot(fd_smry_demog) + aes(x=nhigh, fill=diagg) + geom_histogram(position='dodge') + ggtitle('High (>.8mm) frame displacement for all tasks')
ggsave(p, filename='img/n_fd-gt-thres_hist.png')
