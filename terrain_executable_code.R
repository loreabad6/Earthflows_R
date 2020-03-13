## To be computed on the SAGA GUI: LS Factor, Stream Power Index and Topographic Wetness Index

library(raster, quietly = T)
dem = raster('input_dem/dsm_filled_sa2.tif') 
crs(dem) = '+init=epsg:2193'

writeRaster(dem, 'input_dem/dsm_sa2.sgrd', format = 'SAGA', overwrite = T, NAflag = 0, prj = T)

library(RSAGA)
#saga # Copy the results of this to the env setting
env = rsaga.env(
  path = "C:\\Users\\b1066081\\Desktop\\saga-7.5.0_x64",
  modules = "C:\\Users\\b1066081\\Desktop\\saga-7.5.0_x64\\tools"
  # cmd =  "C:\\Users\\b1066081\\Desktop\\saga-7.5.0_x64\\saga_cmd.exe"
)

rsaga.slope.asp.curv(
  in.dem = "input_dem/dsm_sa2.sgrd", 
  out.slope = "out_products/slope_sa2.sgrd",
  out.aspect = "out_products/slope_sa2.sgrd",
  out.cgene = "out_products/cgene_sa2.sgrd",
  out.cplan = "out_products/cplan_sa2.sgrd",
  out.cprof = "out_products/cprof_sa2.sgrd",
  out.ccros = "out_products/ccros_sa2.sgrd",
  out.clong = "out_products/clong_sa2.sgrd",
  out.cmaxi = "out_products/cmaxi_sa2.sgrd",
  out.cmini = "out_products/cmini_sa2.sgrd", 
  unit.slope = "degrees", env = env,
  method = "poly2zevenbergen"
)

rsaga.geoprocessor(
  'ta_morphometry', 14, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    HO='out_products/slhgt_sa2.sgrd', 
    HU='out_products/vldpt_sa2.sgrd',
    NH='out_products/nrhgt_sa2.sgrd',
    SH='out_products/sthgt_sa2.sgrd',
    MS='out_products/mdslp_sa2.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 9, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    GRADIENT='out_products/ddgrd_sa2.sgrd', 
    OUTPUT = 2
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 10, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    MBI='out_products/mbidx_sa2.sgrd' 
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 18, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    TPI='out_products/tpidx_sa2.sgrd',
    RADIUS_MIN=0,
    RADIUS_MAX=20
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 1, 
  list(
    ELEVATION='input_dem/dsm_sa2.sgrd', 
    RESULT='out_products/cvidx_sa2.sgrd', 
    METHOD=1,
    NEIGHBOURS=1
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 16, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    TRI='out_products/tridx_sa2.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 20, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    TEXTURE='out_products/textu_sa2.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 23, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    MRN='out_products/mridx_sa2.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 15, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    TWI='out_products/sagaw_sa2.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 7, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    LENGTH='out_products/sllgt_sa2.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_lighting', 3, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    VISIBLE='out_products/visky_sa2.sgrd',
    SVF='out_products/svfct_sa2.sgrd',
    METHOD=1,
    DLEVEL=3
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_lighting', 5, 
  list(
    DEM='input_dem/dsm_sa2.sgrd', 
    POS='out_products/posop_sa2.sgrd',
    NEG='out_products/negop_sa2.sgrd',
    METHOD=0,
    DLEVEL=3
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 0, 
  list(
    ELEVATION='input_dem/dsm_sa2.sgrd', 
    FLOW='int_products/flowsa2.sgrd', 
    METHOD=0
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_channels', 0, 
  list(
    ELEVATION='input_dem/dsm_sa2.sgrd', 
    CHNLNTWRK='int_products/chnet_sa2.sgrd', 
    INIT_GRID='int_products/flow_sa2.sgrd', 
    INIT_VALUE=1000000
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_channels', 3, 
  list(
    ELEVATION='input_dem/dsm_sa2.sgrd',
    CHANNELS='int_products/chnet_sa2.sgrd',
    DISTANCE='out_products/vdcnw_sa2.sgrd'
  ),
  env = env
)


library(gdalUtils)
files = list.files(path = "./out_products", pattern = "sa2.*sdat$", full.names = T)
batch_gdal_translate(
  infiles = files,
  outdir = "./out_products",
  outsuffix = ".tif"
)
