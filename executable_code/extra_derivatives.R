library(terrain)
library(sf)
library(here)
dir = "terrain"

env = init_saga(path = "software/saga-7.6.1_x64/")
elev_to_channel(
  elev_sgrd = here(dir, "input_dsm", "dsm_sa1.sgrd"),
  flow_sgrd = here(dir, "out_products", "sa1_flow.sgrd"),
  out_dir = here(dir, "out_products"),
  prefix = "sa1_", init_value = 1e4,
  chnet = T, chnet_shp = T, vdcnw = T, 
  envir = env 
)

elev_to_channel(
  elev_sgrd = here(dir, "input_dsm", "dsm_sa2.sgrd"),
  flow_sgrd = here(dir, "out_products", "sa2_flow.sgrd"),
  out_dir = here(dir, "out_products"),
  prefix = "sa2_", init_value = 1e4,
  chnet = T, chnet_shp = T, vdcnw = T, 
  envir = env 
)

terrain_to_tif(here(dir, "out_products"))
