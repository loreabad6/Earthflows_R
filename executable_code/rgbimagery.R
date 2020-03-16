# setwd('D:\\STEC\\earthflows\\')

#---- Code to resample RGBI to DSM resolution (1x1m) ----
#### This did not work, had to do it on ArcGIS

# library(raster)
# 
# dsm = raster('data/OBIA_Daniel/2016_HRC_DSM_tiraumea.tif') 
# rgbi = stack('data/OBIA_Daniel/HRC_2016_RGBI_mosaic_tiraumea.kea')
# 
# crs = crs(rgbi)
# crs(dsm) = crs
# 
# rgbi_resample = resample(
#   rgbi, dsm, 
#   filename = 'data/OBIA_Daniel/HRC_2016_RGBI_mosaic_tiraumea_resample.tif',
#   prj = T, method = 'ngb'
# )

#---- Code to clip and resample 2010/11 image ----

rgb2010 = stack('Q:\\Manawatu_Data\\Horizons_Regional_Council_imagery\\2011\\Region_kea\\manawatu-whanganui-04m-rural-aerial-photos-2010-2011.kea')
rgbi2016 = stack('data/OBIA_Daniel/HRC_2016_RGBI_mosaic_tiraumea.kea')

rgb2010_tiraumea = crop(rgb2010, rgbi2016, prj = T, filename = 'data/OBIA_Daniel/HRC_2011_RGB_tiraumea.tif')

dsm = raster('data/OBIA_Daniel/2016_HRC_DSM_tiraumea.tif') 

crs = crs(rgbi2016)
crs(dsm) = crs

rgbi_resample = resample(
  rgb2010_tiraumea, dsm, 
  filename = 'data/OBIA_Daniel/HRC_2011_RGB_tiraumea_resample.tif',
  prj = T, method = 'ngb'
)

#---- Code to compute indices on RGB imagery ----

# RGB process
## Load data as stack
rgb = stack('data/OBIA_Daniel/HRC_2011_RGB_tiraumea_resample.tif')

## Convert data to brick for faster processing
rgb_b = brick(rgb)

## Calculate brightness
brightness_rgb = (rgb_b[[1]] + rgb_b[[2]] +rgb_b[[3]]) / 3
writeRaster(brightness_rgb, 'data/OBIA_Daniel/HRC_2011_RGB_tiraumea_resample_brightness.tif')

# ---------------------------------
# RGBI process
## Load data as stack
rgbi = stack('data/OBIA_Daniel/HRC_2016_RGBI_mosaic_tiraumea_resample.tif')

## Convert data to brick for faster processing
rgbi_b = brick(rgbi)

## Calculate NDVI
ndvi = (rgbi_b[[4]] - rgbi_b[[1]]) / (rgbi_b[[4]] + rgbi_b[[1]]) 
writeRaster(ndvi,'data/OBIA_Daniel/HRC_2016_RGBI_mosaic_tiraumea_resample_ndvi.tif')

## Calculate GNDVI
gndvi = (rgbi_b[[4]] - rgbi_b[[2]]) / (rgbi_b[[4]] + rgbi_b[[2]]) 
writeRaster(gndvi,'data/OBIA_Daniel/HRC_2016_RGBI_mosaic_tiraumea_resample_gndvi.tif')

## Calculate brightness
brightness_rgbi = (rgbi_b[[1]] + rgbi_b[[2]] +rgbi_b[[3]]) / 3
writeRaster(brightness_rgbi,'data/OBIA_Daniel/HRC_2016_RGBI_mosaic_tiraumea_resample_brightness.tif')