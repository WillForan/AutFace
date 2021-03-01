#!/usr/bin/env Rscript
# 20210202 WF - write table with some example files for MVM

source('funcs.R') # read_dmg, mkbetas

# get all glms
f <- Sys.glob('../glm/*/*_glm_bucket-FaceVsCar.nii.gz')
briks <- c("face-car_corr_GLT")

# format glms like Subj .... InputFile
betas <- mkbetas(f, briks)

dmg <- read_dmg()
mvmtable <- inner_join(dmg, betas, by=c("Subj","timepoint"))
write.table(mvmtable, 'txt/mvm-faceCar.tsv', quote=F, row.names=F)
