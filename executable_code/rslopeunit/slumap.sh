#!/bin/bash

# register GeoTIFF file to be used in current mapset:
r.external input=/home/Earthflows_R/data_rs/dsm_filled_sa1.tif output=dsm_sa1

# define output directory for files resulting from GRASS calculation:
v.external.out output=/home/Earthflows_R/executable_code/rslopeunit/results/

# run r.slopeuntis module
# demmap = DSM map for subset area 1
# slumap = resulting slope units
# thresh = in square meters, start flow accumulation. value taken from 
#           https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2019JF005056 
#           for initial testing
# circularvariance [c] = between 0 and 1. normally obtained through an interation 
#                        process. For testing I took the optimal values found here: 
#                        https://link.springer.com/article/10.1007/s10346-019-01279-4
# areamin [a] = in square meters. see above
# reductionfactor = 5, values larger than 5 are recommended
# maxiteration = 10 -- arbitrary and from literature 
r.slopeunits demmap=dsm_sa1 slumap=slumap_sa1 thresh=8e5 circularvariance=0.05 areamin=100000 reductionfactor=5 maxiteration=10
