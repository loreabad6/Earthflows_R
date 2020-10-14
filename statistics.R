# setwd('D:\\STEC\\earthflows\\')

#---- Code to compute zonal statistics on earthflow polygons

#' Load rasters as proxy objects ----
library(stars)
#' Set the path to terrain derivatives
file_path = "//shares/sfs_0165_1/ZGIS/RESEARCH/02_PROJECTS/01_P_330001/119_STEC/04_Data/Earthflows/selected_study_areas/study_area_1/out_terrain_products/"
#' List the files of interest, in this case Study Area 1, and GoeTIFF files
files = list.files(path = file_path, pattern = "_sa1.tif$", full.names = T)
#' Filter the files to those computed with the original DEM and the 3x3 filtered DEM
filtered = files[grep("^(?!.*7x7|.*5x5|.*3m)", files, perl = T)]
#' Load the files in a single stars proxy object 
#' with one attribute per terrain derivative (leave `along` as `NA_integer_` for that)
derivatives = read_stars(filtered, proxy = T) 

#' Load reference data ----
library(sf)
library(dplyr)
library(tibble)
#' Reference data for manually delineated earthflows
ef = st_read('data_reference/earthflow_statistics.shp') %>% 
  select(Area_m2, Compactnes, Density, DSMmaxmin, elev_by_le, Length_m, LengthWidt) %>% 
  rowid_to_column(var = 'ID') %>% 
  st_transform(crs = st_crs(derivatives))

#' Filter those earthflows on the area of interst
ef_aoi = st_filter(ef, st_as_sfc(st_bbox(derivatives)))

#' Compute zonal statistics
#' @param stars_object stars object from where the statistics will be calculated
#' @param sf_object object on which the aggregation will occur
#' @param aggregation_functions list of descriptive statistic functions to compute
zonal_statistics = function(stars_object, sf_object, aggregation_functions) {
  
  compute_stat = function(fun) {
    var_names = names(stars_object) %>% 
      stringr::str_replace(".tif","") %>% 
      lapply(function(x) paste0(x, "_", noquote(fun)))
    
    skewfun = function(x, ...) e1071::skewness(x, ...)
    q1fun = function(x, ...) quantile(x, probs = 0.25)
    q3fun = function(x, ...) quantile(x, probs = 0.75)
    fun = ifelse(
      fun == 'skewness', skewfun, 
      ifelse(
        fun == 'q1', q1fun, 
        ifelse(
          fun == 'q3', q3fun,
        )
      )
    )
    
    a = aggregate(stars_object[sf_object], by = sf_object, FUN = fun, na.rm = TRUE) %>% st_as_sf()
    names(a) = c(var_names, 'geometry')
    a
  }
  
  stats = lapply(aggregation_functions, compute_stat)
  do.call('cbind', c(stats, sf_column_name = 'geometry')) %>% 
    select(!contains('geometry.')) %>% 
    st_join(sf_object)
}

#' Apply zonal stats function to terrain derivatives over earthflow objects. 
derivatives_stats = zonal_statistics(
  derivatives, 
  ef_sa, 
  list('mean','sd','max','min','median','skewness', 'q1', 'q3')
)

