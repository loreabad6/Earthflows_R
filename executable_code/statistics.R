# setwd('D:\\STEC\\earthflows\\')

#---- Code to compute zonal statistics on earthflow polygons

## @knitr libs
#' Load libraries
library(sf)
library(dplyr)
library(tibble)
library(tidyr)
library(ggplot2)
library(stars)

## @knitr derivativesProxy
#' Load rasters as proxy objects ----
#' Set the path to terrain derivatives
# file_path = "G:\\STEC\\04_Data\\Earthflows\\selected_study_areas\\complete_tiraumea_catchment\\derivatives"
file_path = "//shares/sfs_0165_1/ZGIS/RESEARCH/02_PROJECTS/01_P_330001/119_STEC/04_Data/Earthflows/selected_study_areas/study_area_1/out_terrain_products/"
#' List the files of interest: GeoTIFF files
files = list.files(path = file_path, pattern = ".tif$", full.names = T)
#' Filter the files to those computed with the original DEM and the 3x3 filtered DEM
filtered = files[grep("^(?!.*7x7|.*5x5|.*3m)", files, perl = T)]
#' Filter files for the DEM computed at 3m resample
filtered_3m = files[grep("^(.*3m)", files, perl = T)]
#' Load the files in a single stars proxy object 
#' with one attribute per terrain derivative (leave `along` as `NA_integer_` for that)
derivatives = read_stars(filtered, proxy = T) 
#' 3m data is loaded separate since resolution differs
derivatives_3m = read_stars(filtered_3m, proxy = T)

## @knitr refEarthflows
#' Load reference data ----
#' Reference data for manually delineated earthflows
ef = st_read('data_reference/earthflow_statistics.shp', quiet = T) %>% 
  select(Area_m2, Compactnes, Density, DSMmaxmin, elev_by_le, Length_m, LengthWidt) %>% 
  rowid_to_column(var = 'ID') 

## @knitr refEarthflowsAOI
#' Filter those earthflows on the area of interest
ef_aoi = ef %>% 
  st_transform(crs = st_crs(derivatives)) %>% 
  st_filter(ef, st_as_sfc(st_bbox(derivatives)))

## @knitr zonalStatsFun
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
    q1fun = function(x, ...) quantile(x, probs = 0.25, ...)
    q3fun = function(x, ...) quantile(x, probs = 0.75, ...)
    fun = ifelse(
      fun == 'skewness', skewfun, 
      ifelse(
        fun == 'q1', q1fun, 
        ifelse(
          fun == 'q3', q3fun, fun
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

## @knitr zonalStatsCalc
#' Apply zonal stats function to terrain derivatives over earthflow objects. 
derivatives_stats1 = zonal_statistics(
  derivatives, 
  ef_aoi, 
  list('mean','sd','max','min','median','skewness', 'q1', 'q3')
)
derivatives_stats2 = zonal_statistics(
  derivatives_3m, 
  ef_aoi, 
  list('mean','sd','max','min', 'q1','median', 'q3', 'skewness')
)

stats = cbind(derivatives_stats1, derivatives_stats2) %>% 
  select(ID, !contains('.')) 

## @knitr dataWrangling
stats_long = stats %>% 
  rename('shape_area' = Area_m2, 'shape_compactness' = Compactnes, 
         'shape_density' = Density, 'dsm_maxmin' = DSMmaxmin,
         'shape_elevbylength' = elev_by_le, 'shape_length' = Length_m, 
         'shape_lengwidth' = LengthWidt) %>% 
  pivot_longer(!c(ID, geometry)) %>% 
  separate(col = 'name', into = c('derivative', 'extra'), extra = 'merge') %>% 
  separate(col = 'extra', into = c('datatype', 'statistic'), fill = 'left') %>% 
  mutate(datatype = ifelse(is.na(datatype), 'original', datatype)) %>% 
  mutate(derivative = ifelse(derivative == 'twi', 'twidx', derivative)) %>% 
  mutate(units = case_when(
    derivative %in% c('aspect','ddgrd', 'slope') ~ 'degree', 
    derivative %in% c('negop', 'posop', 'shade') ~ 'radian', 
    derivative %in% c('visky') ~ '%', 
    derivative %in% c('ccros', 'cgene', 'clong', 'cmaxi', 'cmini', 'cplan', 'cprof') ~ '1/m', 
    derivative %in% c('dsm', 'slhgt', 'sllgt', 'sthgt', 'vdcnw', 'vldpt') ~ 'm', 
    derivative %in% c('lsfct', 'mbidx', 'mdslp', 'mridx', 'nrhgt', 'sagaw', 'spidx', 'svfct', 'tpidx', 'tridx', 'twidx') ~ '', #nondimensional
    derivative %in% c('cvidx', 'textu') ~ 'unknown',
    statistic %in% c('area') ~ 'm^2',
    statistic %in% c('lengwidth', 'compactness', 'density', 'elevbylength') ~ '',
    statistic %in% c('length', 'maxmin') ~ 'm'
  )) %>% 
  select(-geometry, everything(), geometry) %>% 
  st_as_sf() 

## @knitr savingData
#' Save computed statistics
save(stats, file = 'statistics/earthflow_stats_wide.Rda')
save(stats_long, file = 'statistics/earthflow_stats_long.Rda')
# st_write(stats_long, "statistics/earthflow_ref_stats.shp")
# st_write(stats_long, "statistics/earthflow_ref_stats.geojson")
# st_write(stats_long, "statistics/earthflow_ref_stats.gpkg")
