## code to prepare `DATASET` dataset goes here

usethis::use_data(DATASET, overwrite = TRUE)
setwd('~/Documents/eSTZwritR/data-raw')

library(terra)

precip <- rast('prism_precip/PRISM_ppt_30yr_normal_800mM4_annual_bil.bil')
temp <- rast('prism_tmean/PRISM_tmean_30yr_normal_800mM5_annual_bil.bil')

writeRaster(precip, '../inst/extdata/PRISM_ann_ppt.tif')
writeRaster(temp, '../inst/extdata/PRISM_ann_temp.tif')
