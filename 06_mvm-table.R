#!/usr/bin/env Rscript
# 20210202 WF - write table with some example files for MVM

suppressPackageStartupMessages({library(dplyr);library(tidyr)})

coef0 <- function(x) sprintf("[%s#0_Coef]", x)

# need 'Subj' and it should be first
dmg <- read.csv('txt/id_dmg.csv') %>% rename(Subj=id) %>% relocate(Subj)

# get all glms
f <- Sys.glob('../glm/*/*_glm_bucket-FaceVsCar.nii.gz')
briks <- c("face-car_corr_GLT")

# format glms like Subj .... InputFile
betas<- expand.grid(InputFile=f, brik=briks) %>%
    mutate(
        id_ses=stringr::str_extract(InputFile, "\\d+_ses-\\d+") %>% gsub('_ses', '', .),
        InputFile=paste0(InputFile, coef0(brik))
    ) %>%
    separate(id_ses,c('Subj','timepoint')) %>%
    mutate(across(c(Subj,timepoint), as.numeric)) %>%
    relocate(InputFile, .after=last_col())

mvmtable <- inner_join(dmg, betas, by=c("Subj","timepoint"))
write.table(mvmtable, 'txt/mvm-faceCar.tsv', quote=F, row.names=F)
