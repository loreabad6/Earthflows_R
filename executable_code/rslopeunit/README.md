
## Testing `r.slopeunits`

[Slope units delineation](http://geomorphology.irpi.cnr.it/tools/slope-units) has been developed and described by Alvioli et al. ([2016](https://gmd.copernicus.org/articles/9/3975/2016/), [2020](https://www.sciencedirect.com/science/article/pii/S0169555X20300969)) as a useful tool to subdivide terrain units and use as an input layer for landslide susceptibility analyses.

The usage of the software requires GRASS GIS, and it is designed to run ideally on a Linux environment. To bypass any difficulties regarding operating systems, I created a Docker Image of an Ubuntu interface with GRASS GIS 7.8, Python 3, and r.slopeunits setup ready for usage. 

How-to guide: 
  
1. Inside the Command Prompt, run the docker image inside a new container: 
```
docker run -it --name container_name loreabad6/rslopeunits:v1.0
```

  a. Alternatively, mount a volume (i.e. a local directory containing a DSM model) ar runtime to the container:
```
docker run -it -v  local_path:/home_destination_path --name container_name loreabad6/rslopeunits:v1.0
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

3. Run the module for our study case - Work in progress...

So far, if we mount a volume in the container, we should in theory be able to run the slope units module. I just need to give myself a crash course on GRASS from the CLI, see options [here](https://grass.osgeo.org/grass78/manuals/grass7.html) and [here](https://ncsu-geoforall-lab.github.io/geospatial-modeling-course/grass/data_acquisition.html).

Then getting an idea of the initial parameters to test with goes hand in hand with analyzing the papers below.  

Ideally, I would write a bash (.sh) script in this section with my testing commands in the form:

```
r.slopeunits demmap=[dem] slumap=[output_SU_map] thresh=[t, square meters] circularvariance=[c] areamin=[a, square meters] reductionfactor=[r, r>2] maxiteration=[max number of iterations]
```
And then let it execute and save the results. 

### References

- Alvioli M., Guzzetti F., Marchesini I. (2020). Parameter-free delineation of slope units and terrain subdivision of Italy. Geomorphology 258, 107124. https://doi.org/10.1016/j.geomorph.2020.107124

- Alvioli M., Marchesini I., Reichenbach P., Rossi M., Ardizzone F., Fiorucci F., Guzzetti F. (2016). Automatic delineation of geomorphological slope units with r.slopeunits v1.0 and their optimization for landslide susceptibility modeling. Geoscientific Model Development 9, 3975-3991. https://doi.org/10.5194/gmd-9-3975-2016