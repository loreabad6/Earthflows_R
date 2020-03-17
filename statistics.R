# setwd('D:\\STEC\\earthflows\\')

#---- Code to compute zonal statistics on earthflow polygons

## Load rasters as proxy objects
library(stars)
files = list.files(path = "./terrain/derivatives", pattern = "*sa1.tif$", full.names = T)
t = read_stars(files, proxy = T, along = 'derivative') #

## Load polygons 
library(sf)
library(dplyr)
library(tibble)
ef = st_read('data_reference/earthflow_statistics.shp') %>% 
  select(Area_m2, Compactnes, Density, DSMmaxmin, elev_by_le, Length_m, LengthWidt) %>% 
  rowid_to_column(var = 'ID')
ef2 = ef[1:2,]

zonal_statistics = function(stars_object, sf_object, aggregation_function) {
  var_names = names(stars_object$attr) %>% 
    stringr::str_replace(".tif","") %>% 
    lapply(function(x) paste0(x, "_", noquote(aggregation_function)))
  
  a = aggregate(stars_object, by = sf_object, FUN = aggregation_function) %>% st_as_sf()
  names(a) = c(var_names, 'geometry')
  a
}

zonal_statistics(t, ef2, 'mean')
