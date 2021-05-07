#!/bin/bash

# register GeoTIFF file to be used in current mapset:
r.external input=/home/rslopeunit/data/dsm_sample.tif output=dsm

# define output directory for files resulting from GRASS calculation:
v.external.out output=/home/rslopeunit/results/

# Navigate to source code for r.slopeunits
cd home/rslopeunit/

# run r.slopeuntis module
#> Usage:
#>  r.slopeunits [-mn] demmap=name [plainsmap=name] slumap=name
#>    [slumapclean=name] [circvarmap=name] [areamap=name] thresh=value
#>    areamin=value [areamax=value] cvmin=value rf=value maxiteration=value
#>    [cleansize=value] [--overwrite] [--help] [--verbose] [--quiet] [--ui]
#> 
#> Flags:
#>   -m   Perform quick cleaning of small-sized areas and stripes
#>   -n   Perform detailed cleaning of small-sized areas (slow)
#> 
#> Parameters:
#>         demmap   Input digital elevation model
#>      plainsmap   Input raster map of alluvial_plains
#>         slumap   Output Slope Units layer (the main output)
#>    slumapclean   Output Slope Units layer (the main output)
#>     circvarmap   Output Circular Variance layer
#>        areamap   Output Area layer; values in square meters
#>         thresh   Initial threshold (m^2).
#>        areamin   Minimum area (m^2) below whitch the slope unit is not further
#>                  segmented
#>        areamax   Maximum area (m^2) above which the slope unit is segmented
#>                  irrespective of aspect
#>          cvmin   Minimum value of the circular variance (0.0-1.0) below which
#>                  the slope unit is not further segmented
#>             rf   Factor used to iterativelly reduce initial threshold:
#>                  newthresh=thresh-thresh/reductionfactor
#>   maxiteration   maximum number of iteration to do before the procedure is in
#>                  any case stopped
#>      cleansize   Slope Units size to be removed
./r.slopeunits demmap=dsm slumap=slumap thresh=1e2 cvmin=0.15 rf=2 areamin=100000 maxiteration=10

# Convert result to vector
r.to.vect input=slumap output=slumap type=area --o --q
