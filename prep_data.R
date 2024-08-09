setwd('/media/steppe/hdd/EmpiricalSeedZones/scripts')

library(tidyverse)
library(sf)

regions_abb <- data.frame( 
  REG_NUM = 1:12, 
  REG_ABB = c('NAA', 'SAG', 'GL', 'MSB', 'MOB', 'ART', 'UCB', 'LCB', 'CPN', 'CGB', 'AK', 'PI')
) 

regions <- st_read( 
  '../data/geodata/doi_unified_regions/DOI_12_Unified_Regions_20180801.shp') |> 
  select(REG_NUM, REG_NAME) |> 
  left_join(regions_abb) 

rm(regions_abb) 

omernik <- st_read( 
  '../data/geodata/us_eco_l3/us_eco_l3.shp' 
) |> 
  select(US_L3CODE, US_L3NAME) |> 
  group_by(US_L3CODE, US_L3NAME) |> 
  summarise(geometry = st_union(geometry)) |> 
  ungroup() |> 
  mutate(US_L3CODE = as.numeric(US_L3CODE)) |> 
  arrange(US_L3CODE) 

omernik <- rmapshaper::ms_simplify(omernik, keep = 0.01, keep_shapes = TRUE) |> 
  st_transform(5070) 

setwd('/media/steppe/hdd/eSTZwritR')
getwd()
usethis::use_data(omernik)
