# Earthflows_R
Calculate terrain derivatives for Earthflow detection. The workflow mainly uses RSAGA. The main documentation of the work can be found here: [Terrain derivatives documentation](https://loreabad6.github.io/Earthflows_R/terrain_derivatives.html).

Basic statistics were computed for manually delineated earthflows in the study area. The computation procedure can be found here: [Terrain statistics for Reference Earthflows](https://loreabad6.shinyapps.io/terrain_statistics/).

This repository is meant to hold the workflow and code, and not the actual generated files, due to their size. The majority of folders will be empty but should be filled with the relevant layers that correspond on each. Mainly it is to keep the structure that the code itself will hold. 

In addition to using R, some parts of the workflow are performed in ArcGIS and eCognition. Since these sections are not coded, they will be thoroughly described to guarantee reproducibility. 

## Testing `r.slopeunits`

[Slope units delineation](http://geomorphology.irpi.cnr.it/tools/slope-units) has been developed and described by Alvioli et al. ([2016](https://gmd.copernicus.org/articles/9/3975/2016/), [2020](https://www.sciencedirect.com/science/article/pii/S0169555X20300969)) as a useful tool to subdivide terrain units and use as an input layer for landslide susceptibility analyses.

The usage of the software requires GRASS GIS, and it is designed to run ideally on a Linux environment. To bypass any difficulties regarding operating systems, I created a Docker Image, accessible [via Docker Hub](https://hub.docker.com/repository/docker/loreabad6/rslopeunits/general) of an Ubuntu interface with GRASS GIS 7.8, Python 3, and r.slopeunits setup ready for usage. 

How-to guide: 

1. Inside the Command Prompt, run the docker image inside a new container: 
```
docker run -it --name container_name loreabad6/rslopeunits
```

2. Double check `r.slopeunits` is accessible. Run:
  - Inside Ubuntu:
```
# grass78
```
  - Inside GRASS:
```
# r.slopeunits --help
```

3. Copy data (i.e. a DSM model) inside the container:
```
docker cp path_to_file.tif contained_name:/destination_path
```

### References

- Alvioli M., Guzzetti F., Marchesini I. (2020). Parameter-free delineation of slope units and terrain subdivision of Italy. Geomorphology 258, 107124. https://doi.org/10.1016/j.geomorph.2020.107124

- Alvioli M., Marchesini I., Reichenbach P., Rossi M., Ardizzone F., Fiorucci F., Guzzetti F. (2016). Automatic delineation of geomorphological slope units with r.slopeunits v1.0 and their optimization for landslide susceptibility modeling. Geoscientific Model Development 9, 3975-3991. https://doi.org/10.5194/gmd-9-3975-2016