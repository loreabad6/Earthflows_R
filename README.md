# Earthflow detection based on LiDAR data and terrain derivatives using an OBIA approach

This repository contains the main steps followed to calculate terrain derivatives for Earthflow detection. The workflow mainly uses RSAGA. The main documentation of the work can be found here: [Terrain derivatives documentation](https://loreabad6.github.io/Earthflows_R/terrain_derivatives.html).

Basic statistics were computed for manually delineated earthflows in the study area. The computation procedure can be found here: [Terrain statistics for Reference Earthflows](https://loreabad6.shinyapps.io/terrain_statistics/).

This repository is meant to hold the workflow and code, and not the actual generated files, due to their size. The majority of folders will be empty but should be filled with the relevant layers that correspond on each. Mainly it is to keep the structure that the code itself will hold. 

In addition to using R, some parts of the workflow are performed in ArcGIS and eCognition. Since these sections are not coded, they will be thoroughly described to guarantee reproducibility. OBIA is mainly implemented through eCognition and is currently work in progress. 

For a test on the `r.slopeunit` module developed for GRASS 7.8 see the folder [with executable code here](executable_code/rslopeunit).

## Acknowledgements
This research work is supported by the New Zealand Ministry of Business, Innovation and Employment research program “Smarter Targeting of Erosion Control (STEC)” (Contract C09X1804).