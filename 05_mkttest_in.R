#!/usr/bin/env Rscript

# make table of diag and file
# 
library(dplyr)
library(stringr)
d <- read.table('txt/demog.txt', header=T) %>% select(-ScanID, -ageg)
glms <-
    data.frame(
       InputFile=Sys.glob('../glm/*/*_glm_bucket-FaceVsCar.nii.gz')) %>%
    mutate(Subj=str_extract(InputFile, '(?<=/)\\d{3}') %>% as.numeric,
           ses=str_extract(InputFile, '(?<=ses-)\\d') %>% as.numeric,)

d_glms <- inner_join(glms, d) %>% select(Subj,InputFile, diagg) 
write.table(d_glms, "txt/dt/glm_faceVcar.txt", row.names=F, quote=F)

