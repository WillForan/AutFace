#!/usr/bin/env Rscript

# 20210204WF - read in all zscored roi-roi correlations for
#  AAL subset7 (see mk_aal_subset_mask.bash and 03_rest-ROIcorr.bash)
#  make very (all roi-roi pairs as columns) dataframe
#  and merge with demographics

library(dplyr)

# N.B. should be sorted. so names match rois (even after unique)
roi_names <- unique(read.table('masks/AAL3/AAL_subset7.nii.txt')$V2)
zcorr_files <- Sys.glob('../restcorr/sub-*/AAL_subset7.zval.1D')
# pull out as very wide roi-roi
wide <-
    lapply(zcorr_files, function(f){
        LNCDR::roicormat_wide(f, roi_names=roi_names) %>%
            mutate(id=stringr::str_extract(f, 'sub-\\d+_ses-\\d'))
    }) %>%
    bind_rows %>%
    mutate(id=gsub('sub-|ses-','', id)) %>%
    tidyr::separate(id, c('id','ses'))

               
# add demographic info
dmg <- read.csv('txt/id_dmg.csv') %>% rename(ses=timepoint)
roiroi_dmg <- merge(wide, dmg, by=c("id","ses"))
