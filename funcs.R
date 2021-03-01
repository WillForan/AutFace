suppressPackageStartupMessages({require(dplyr);require(tidyr)})

coef0 <- function(x) sprintf("[%s#0_Coef]", x)

# format glms like Subj .... InputFile
# inputslike
#  f <- Sys.glob('../glm/*/*_glm_bucket-FaceVsCar_glt-10.nii.gz')
#  briks <- c("Acorr", "Amem", "Ccorr","Cmem","Ucorr", "Umem")
mkbetas<- function(f, briks) {
   # input files like
   expand.grid(InputFile=f, brik=briks) %>%
    mutate(
        id_ses=stringr::str_extract(InputFile, "\\d+_ses-\\d+") %>%
           gsub('_ses', '', .),
        InputFile=paste0(InputFile, coef0(brik))
    ) %>%
    separate(id_ses,c('Subj','timepoint')) %>%
    mutate(across(c(Subj,timepoint), as.numeric)) %>%
    relocate(InputFile, .after=last_col())
}

# need 'Subj' and it should be first
read_dmg <- function(dmgcsv='txt/id_dmg.csv') {
   dmg <- read.csv(dmgcsv) %>% rename(Subj=id) %>% relocate(Subj)
}
