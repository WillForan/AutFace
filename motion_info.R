#!/usr/bin/env Rscript
library(stringr)
library(dplyr)
library(ggplot2)
library(cowplot)
theme_set(theme_cowplot())

# 20201021WF - init
demog <- read.table('txt/demog.txt', header=T)

allfd_files <- Sys.glob('../preproc/*/*/ses-*/sub-*_bold/motion_info/fd.txt')
fd_smry <- lapply(allfd_files, function(f, fdthres=.8) { 
    read.table(f) %>%
        summarise(mx=max(V1), mean=mean(V1), med=median(V1), nhigh=length(which(V1>fdthres))) %>%
        mutate(Subj=str_match(f,'(?<=sub-)\\d+'),
               ses=str_match(f,'(?<=ses-)\\d+'),
               task=str_match(f,'(?<=preproc/).*?(?=/)'))}) %>%
    bind_rows
fd_smry_demog <- merge(fd_smry, demog, all.x=T, on='Subj')
    
p <- ggplot(fd_smry_demog) + aes(x=nhigh, fill=diagg) + geom_histogram(position='dodge') + ggtitle('High (>.8mm) frame displacement for all tasks')
ggsave(p, filename='img/n_fd-gt-thres_hist.png')
