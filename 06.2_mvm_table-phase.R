#!/usr/bin/env Rscript
# 20210202 WF - write table with some example files for MVM
source('funcs.R') # read_dmg, mkbetas


# get all glms
f <- Sys.glob('../glm/*/*_glm_bucket-FaceVsCar.nii.gz')
briks <- c("Acorr", "Amem", "Ccorr","Cmem","Ucorr", "Umem")
dmg <- read_dmg()
betas <- mkbetas(f,briks)

mvmtable <- inner_join(dmg, betas, by=c("Subj","timepoint")) %>%
   rename(phase=brik)
write.table(mvmtable, 'txt/mvm-phase.tsv', quote=F, row.names=F)
write.table(mvmtable %>% filter(timepoint==1), 'txt/mvm-phase_ses-1.tsv', quote=F, row.names=F)
