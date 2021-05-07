
# Testing `r.slopeunits`

[Slope units delineation](http://geomorphology.irpi.cnr.it/tools/slope-units) has been developed and described by Alvioli et al. ([2016](https://gmd.copernicus.org/articles/9/3975/2016/), [2020](https://www.sciencedirect.com/science/article/pii/S0169555X20300969)) as a useful tool to subdivide terrain units and use as an input layer for landslide susceptibility analyses.

Unfortunately, I run by some trouble when running the code posted on their website. But, recently during the #vEGU21 the authors of the course provided a [short course ](https://meetingorganizer.copernicus.org/EGU21/session/38902), which provided a virtual machine with updated code and slides to learn about the method. For now, I do not count with the authorization to share these materials through this repository, but will hope to contact the authors!

The usage of the software requires GRASS GIS, and it is designed to run ideally on a Linux environment. To bypass any difficulties regarding operating systems, I use the [GRASS GIS Docker Image by Mundialis](https://hub.docker.com/r/mundialis/grass-py3-pdal) to run the code.

# How-to guide: 
  
## 1. Create a new container

    - Inside the Command Prompt, run the docker image inside a new container: 
```
docker run -it --name [container_name] mundialis/grass-py3-pdal:stable-ubuntu
```

    - Alternatively, mount a volume (e.g. a local directory containing a DSM/DEM model) at runtime to the container:
```
docker run -it -v [local_path:/home/rslopeunit/] --name [container_name] mundialis/grass-py3-pdal:stable-ubuntu
```

Mountain a container is my preferred setup, since results will be saved to the host and not inside the docker, so I can easily explored them later.

If you already have a setup container, with a mounted volume and some work done, then run this in your command line:

```
docker start [container_name]
docker exec -it [container_name] bash
```
In my case, the container name is `rslopeunits`.

## 2. Double check `r.slopeunits` is accessible.

Here it is important to note that one needs to be in the source code location to be able to run it (at least for my case). This is why once we are there, we call the file as `./r.slopeunits`.    
      
```
# Inside the container
grass78
# Inside GRASS, navigate to the source code location and look for the help.
# Assuming the volume mounted is home/rslopeunit, and the code is there, then:
cd home/rslopeunit ## path_to_code
./r.slopeunits --help

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
```

### 3. Run r.slopeunits for our case study.

We will create a temporal location based on our georeferenced TIFF and we will execute a bash script that will export the results to the mounted volume, see [more details on batch jobs in GRASS here](https://grass.osgeo.org/grass78/manuals/grass7.html#batch-jobs-with-the-exec-interface).

```
# Give shell file execution rights
chmod ugo+x home/rslopeunit/slumap.sh
# Navigate to the data folder
cd home/rslopeunit/data/
# Run shell file
grass78 --tmp-location home/rslopeunit/data/dsm_sample.tif --exec /home/rslopeunit/slumap.sh
```

**NOTE!** For some reason, the bash script won't run properly. So until finding a solution to that, I ran the code inside `grass78`. So basically:

```
## On the command line
# Navigate to the data location
cd home/rslopeunit/data/
# Create a temporary location
grass78 --tmp-location dsm_sample.tif
## inside grass
# register GeoTIFF file to be used in current mapset:
r.external input=/home/rslopeunit/data/dsm_sample.tif output=dsm
# define output directory for files resulting from GRASS calculation:
v.external.out output=/home/rslopeunit/results/
# Navigate to source code for r.slopeunits
cd home/rslopeunit/
# Run r.slopeunits
./r.slopeunits demmap=dsm slumap=slumap thresh=1e2 cvmin=0.15 rf=2 areamin=100000 maxiteration=10
# Convert result to vector
r.to.vect input=slumap output=slumap type=area --o --q
```

# References

- Alvioli M., Guzzetti F., Marchesini I. (2020). Parameter-free delineation of slope units and terrain subdivision of Italy. Geomorphology 258, 107124. https://doi.org/10.1016/j.geomorph.2020.107124

- Alvioli M., Marchesini I., Reichenbach P., Rossi M., Ardizzone F., Fiorucci F., Guzzetti F. (2016). Automatic delineation of geomorphological slope units with r.slopeunits v1.0 and their optimization for landslide susceptibility modeling. Geoscientific Model Development 9, 3975-3991. https://doi.org/10.5194/gmd-9-3975-2016