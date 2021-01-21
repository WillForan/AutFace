#!/usr/bin/env Rscript
library(stringr)
library(dplyr)
library(ggplot2)
library(cowplot)
theme_set(theme_cowplot())

allfd_files <- Sys.glob('../preproc/*/*/ses-*/sub-*_bold/motion_info/fd.txt')
fd_smry <- lapply(allfd_files, function(f, fdthres=.8) { 
    read.table(f) %>%
        summarise(mx=max(V1), mean=mean(V1), med=median(V1), nhigh=length(which(V1>fdthres))) %>%
        mutate(Subj=str_match(f,'(?<=sub-)\\d+'),
               ses=str_match(f,'(?<=ses-)\\d+'),
               task=str_match(f,'(?<=preproc/).*?(?=/)'))}) %>%
    bind_rows
write.csv(fd_smry, 'txt/fd_summary.csv', row.names=F)

# see demog_motion.R for merging
