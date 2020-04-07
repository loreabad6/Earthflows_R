## To be computed on the SAGA GUI: Stream Power Index 
## (Needs first Specific Cathcment Area) 

# Prepare data ----

library(raster)
dsm = raster('data_rs/2016_HRC_DSM_tiraumea.tif') 
crs(dsm) = '+init=epsg:2193'

writeRaster(dsm, 'terrain/input_dsm/dsm.sgrd', format = 'SAGA', overwrite = T, NAflag = 0, prj = T)

library(RSAGA)
env = rsaga.env(
  path = "software\\saga-7.6.1_x64",
  modules = "software\\saga-7.6.1_x64\\tools"
  # cmd =  "software\\saga-7.6.1_x64\\saga_cmd.exe" 
  # For some reason this last one throws an error, but when commented out it still works. 
)

rsaga.filter.simple(
  in.grid = 'terrain/input_dsm/dsm.sgrd', 
  out.grid = 'terrain/input_dsm/dsm_3x3.sgrd', 
  method = 'smooth', radius = 3, mode = 'square', 
  env = env
)

dsm = raster('data_rs/2016_HRC_DSM_tiraumea.tif') 

rgbi = stack('data_rs/HRC_2016_RGBI_mosaic_tiraumea.tif')
crs = crs(rgbi)
crs(dsm) = crs

NAvalue(dsm) = -9999

dsm3 = aggregate(dsm, fact = 3)
writeRaster(dsm3, 'data_rs/2016_HRC_DSM_tiraumea_3m.tif')
writeRaster(
  dsm3, 'terrain/input_dsm/dsm_3m.sgrd', format = 'SAGA', overwrite = T, NAflag = 0, prj = T
)


# ORIGINAL DSM ----
# Morphometry module ----

rsaga.slope.asp.curv(
  in.dem = "terrain/input_dsm/dsm.sgrd", 
  out.slope = "terrain/out_products/slope.sgrd",
  out.aspect = "terrain/out_products/aspect.sgrd",
  out.cgene = "terrain/out_products/cgene.sgrd",
  out.cplan = "terrain/out_products/cplan.sgrd",
  out.cprof = "terrain/out_products/cprof.sgrd",
  out.ccros = "terrain/out_products/ccros.sgrd",
  out.clong = "terrain/out_products/clong.sgrd",
  out.cmaxi = "terrain/out_products/cmaxi.sgrd",
  out.cmini = "terrain/out_products/cmini.sgrd", 
  unit.slope = "degrees", unit.aspect = "degrees",
  env = env,
  method = "poly2zevenbergen"
)

rsaga.geoprocessor(
  'ta_morphometry', 14, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    HO='terrain/out_products/slhgt.sgrd', 
    HU='terrain/out_products/vldpt.sgrd',
    NH='terrain/out_products/nrhgt.sgrd',
    SH='terrain/out_products/sthgt.sgrd',
    MS='terrain/out_products/mdslp.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 9, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    GRADIENT='terrain/out_products/ddgrd.sgrd', 
    OUTPUT = 2
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 10, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    MBI='terrain/out_products/mbidx.sgrd' 
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 18, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    TPI='terrain/out_products/tpidx.sgrd',
    RADIUS_MIN=0,
    RADIUS_MAX=20
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 1, 
  list(
    ELEVATION='terrain/input_dsm/dsm.sgrd', 
    RESULT='terrain/out_products/cvidx.sgrd', 
    METHOD=1,
    NEIGHBOURS=1
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 16, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    TRI='terrain/out_products/tridx.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 20, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    TEXTURE='terrain/out_products/textu.sgrd'
  ),
  env = env
)

# Hydrology Module ----
rsaga.geoprocessor(
  'ta_hydrology', 23, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    MRN='terrain/out_products/mridx.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 15, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    TWI='terrain/out_products/sagaw.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 7, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    LENGTH='terrain/out_products/sllgt.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'terrain_analysis',
  'LS Factor (One Step)', 
  list(
    DEM='terrain/input_dsm/dsm.sgrd',
    LS_FACTOR='terrain/out_products/lsfct.sgrd',
    LS_METHOD=0,
    PREPROCESSING=2,
    MINSLOPE=0.0001
  ),
  env = env
)

rsaga.geoprocessor(
  'terrain_analysis',
  'Topographic Wetness Index (One Step)',
  list(
    DEM='terrain/input_dsm/dsm.sgrd',
    TWI='terrain/out_products/twidx.sgrd', 
    FLOW_METHOD=0
  ),
  env = env
)

rsaga.geoprocessor(
  'terrain_analysis',
  'Flow Accumulation (One Step)',
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    TCA='terrain/int_products/flow.sgrd',
    SCA='terrain/int_products/spcar.sgrd',
    PREPROCESSING=0,
    FLOW_ROUTING=0
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 21,
  list(
    SLOPE='terrain/out_products/slope.sgrd',
    AREA='terrain/int_products/spcar.sgrd',
    SPI='terrain/out_products/spidx.sgrd'
  ),
  env = env
)

# Lighting Module ----

rsaga.geoprocessor(
  'ta_lighting', 0, 
  list(
    ELEVATION='terrain/input_dsm/dsm.sgrd',
    SHADE='terrain/out_products/shade.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_lighting', 3, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    VISIBLE='terrain/out_products/visky.sgrd',
    SVF='terrain/out_products/svfct.sgrd',
    METHOD=1,
    DLEVEL=3
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_lighting', 5, 
  list(
    DEM='terrain/input_dsm/dsm.sgrd', 
    POS='terrain/out_products/posop.sgrd',
    NEG='terrain/out_products/negop.sgrd',
    METHOD=0,
    DLEVEL=3
  ),
  env = env
)

# Channel Module ----

rsaga.geoprocessor(
  'ta_hydrology', 0, 
  list(
    ELEVATION='terrain/input_dsm/dsm.sgrd', 
    FLOW='terrain/int_products/flow.sgrd', 
    METHOD=0
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_channels', 0, 
  list(
    ELEVATION='terrain/input_dsm/dsm.sgrd', 
    CHNLNTWRK='terrain/int_products/chnet.sgrd', 
    INIT_GRID='terrain/int_products/flow.sgrd', 
    INIT_VALUE=1000000
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_channels', 3, 
  list(
    ELEVATION='terrain/input_dsm/dsm.sgrd',
    CHANNELS='terrain/int_products/chnet.sgrd',
    DISTANCE='terrain/out_products/vdcnw.sgrd'
  ),
  env = env
)

# 3X3 FILTERED DSM ----
# Morphometry module ---- 

rsaga.slope.asp.curv(
  in.dem = "terrain/input_dsm/dsm_3x3.sgrd", 
  out.slope = "terrain/out_products/slope_3x3.sgrd",
  out.aspect = "terrain/out_products/aspect_3x3.sgrd",
  out.cgene = "terrain/out_products/cgene_3x3.sgrd",
  out.cplan = "terrain/out_products/cplan_3x3.sgrd",
  out.cprof = "terrain/out_products/cprof_3x3.sgrd",
  out.ccros = "terrain/out_products/ccros_3x3.sgrd",
  out.clong = "terrain/out_products/clong_3x3.sgrd",
  out.cmaxi = "terrain/out_products/cmaxi_3x3.sgrd",
  out.cmini = "terrain/out_products/cmini_3x3.sgrd", 
  unit.slope = "degrees", unit.aspect = "degrees",
  env = env,
  method = "poly2zevenbergen"
)

rsaga.geoprocessor(
  'ta_morphometry', 14, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    HO='terrain/out_products/slhgt_3x3.sgrd', 
    HU='terrain/out_products/vldpt_3x3.sgrd',
    NH='terrain/out_products/nrhgt_3x3.sgrd',
    SH='terrain/out_products/sthgt_3x3.sgrd',
    MS='terrain/out_products/mdslp_3x3.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 9, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    GRADIENT='terrain/out_products/ddgrd_3x3.sgrd', 
    OUTPUT = 2
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 10, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    MBI='terrain/out_products/mbidx_3x3.sgrd' 
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 18, 
  list(
    DEM="terrain/input_dsm/dsm_3m.sgrd",
    TPI='terrain/out_products/tpidx_3m.sgrd',
    RADIUS_MIN=0,
    RADIUS_MAX=100
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 1, 
  list(
    ELEVATION='terrain/input_dsm/dsm_3x3.sgrd', 
    RESULT='terrain/out_products/cvidx_3x3.sgrd', 
    METHOD=1,
    NEIGHBOURS=1
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 16, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    TRI='terrain/out_products/tridx_3x3.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_morphometry', 20, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    TEXTURE='terrain/out_products/textu_3x3.sgrd'
  ),
  env = env
)

# Hydrology Module ----
rsaga.geoprocessor(
  'ta_hydrology', 23, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    MRN='terrain/out_products/mridx_3x3.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 15, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    TWI='terrain/out_products/sagaw_3x3.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 7, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    LENGTH='terrain/out_products/sllgt_3x3.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'terrain_analysis',
  'LS Factor (One Step)', 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd',
    LS_FACTOR='terrain/out_products/lsfct_3x3.sgrd',
    LS_METHOD=0,
    PREPROCESSING=2,
    MINSLOPE=0.0001
  ),
  env = env
)

rsaga.geoprocessor(
  'terrain_analysis',
  'Topographic Wetness Index (One Step)',
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd',
    TWI='terrain/out_products/twidx_3x3.sgrd', 
    FLOW_METHOD=0
  ),
  env = env
)

rsaga.geoprocessor(
  'terrain_analysis',
  'Flow Accumulation (One Step)',
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    TCA='terrain/int_products/flow_3x3.sgrd',
    SCA='terrain/int_products/spcar_3x3.sgrd',
    PREPROCESSING=0,
    FLOW_ROUTING=0
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_hydrology', 21,
  list(
    SLOPE='terrain/out_products/slope_3x3.sgrd',
    AREA='terrain/int_products/spcar_3x3.sgrd',
    SPI='terrain/out_products/spidx_3x3.sgrd'
  ),
  env = env
)

# Lighting Module ----

rsaga.geoprocessor(
  'ta_lighting', 0, 
  list(
    ELEVATION='terrain/input_dsm/dsm_3x3.sgrd',
    SHADE='terrain/out_products/shade_3x3.sgrd'
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_lighting', 3, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    VISIBLE='terrain/out_products/visky_3x3.sgrd',
    SVF='terrain/out_products/svfct_3x3.sgrd',
    METHOD=1,
    DLEVEL=3
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_lighting', 5, 
  list(
    DEM='terrain/input_dsm/dsm_3x3.sgrd', 
    POS='terrain/out_products/posop_3x3.sgrd',
    NEG='terrain/out_products/negop_3x3.sgrd',
    METHOD=0,
    DLEVEL=3
  ),
  env = env
)

# Channel Module ----

rsaga.geoprocessor(
  'ta_hydrology', 0, 
  list(
    ELEVATION='terrain/input_dsm/dsm_3x3.sgrd', 
    FLOW='terrain/int_products/flow_3x3.sgrd', 
    METHOD=0
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_channels', 0, 
  list(
    ELEVATION='terrain/input_dsm/dsm_3x3.sgrd', 
    CHNLNTWRK='terrain/int_products/chnet_3x3.sgrd', 
    INIT_GRID='terrain/int_products/flow_3x3.sgrd', 
    INIT_VALUE=1000000
  ),
  env = env
)

rsaga.geoprocessor(
  'ta_channels', 3, 
  list(
    ELEVATION='terrain/input_dsm/dsm_3x3.sgrd',
    CHANNELS='terrain/int_products/chnet_3x3.sgrd',
    DISTANCE='terrain/out_products/vdcnw_3x3.sgrd'
  ),
  env = env
)
# Convert results to .tif ----

library(gdalUtils)
library(stringr)
files_short = list.files(path = "./terrain/out_products", pattern = ".sdat$", full.names = F)
files_as_tif = str_replace(files_short, ".sdat$", ".tif")
existing_files = list.files(path = "./terrain/derivatives", pattern = ".tif$", full.names = F)

'%!in%' = function(x,y)!('%in%'(x,y))

files_to_translate = files_as_tif[files_as_tif %!in% existing_files] %>%
  str_replace(".tif", '.sdat')

files_for_translation = file.path(paste0("./terrain/out_products/",files_to_translate))

batch_gdal_translate(
  infiles = files_for_translation,
  outdir = "./terrain/derivatives",
  outsuffix = ".tif"
)
