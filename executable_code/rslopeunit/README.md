
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

3. Work in progress...

### References

- Alvioli M., Guzzetti F., Marchesini I. (2020). Parameter-free delineation of slope units and terrain subdivision of Italy. Geomorphology 258, 107124. https://doi.org/10.1016/j.geomorph.2020.107124

- Alvioli M., Marchesini I., Reichenbach P., Rossi M., Ardizzone F., Fiorucci F., Guzzetti F. (2016). Automatic delineation of geomorphological slope units with r.slopeunits v1.0 and their optimization for landslide susceptibility modeling. Geoscientific Model Development 9, 3975-3991. https://doi.org/10.5194/gmd-9-3975-2016