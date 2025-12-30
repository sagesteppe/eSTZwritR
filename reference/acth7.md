# An empirical seed transfer zone

This data set is from Johnson et al. 2017, and slightly modified by us.
It is an eSTZ of Eriocoma thurberiana. Johnson, R. C., E. A. Leger, and
Ken Vance-Borland. "Genecology of Thurber’s Needlegrass (Achnatherum
thurberianum \[Piper\] Barkworth) in the Western United States."
Rangeland Ecology & Management 70.4 (2017): 509-517.

## Format

A data frame/tibble/sf with 2 columns

- ID:

  A unique ID for each each polygon, note this includes gaps in the
  numbering.

- GRIDCODE:

  From an ESRI raster, the classification output used during creating
  the product.

- area_ha:

  From ESRI calulcated area of each polygon.

- zone:

  STZ defined by the authors from the GRIDCODE.

- geometry:

  sf geometry column

## Examples

``` r
acth7 <- sf::st_read(file.path(
   system.file(package="eSTZwritR"), "extdata", 'ACTH7.gpkg')
)
#> Reading layer `ACTH7' from data source 
#>   `/home/runner/work/_temp/Library/eSTZwritR/extdata/ACTH7.gpkg' 
#>   using driver `GPKG'
#> Simple feature collection with 4967 features and 4 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -121.5447 ymin: 36.53208 xmax: -111.0114 ymax: 46.35708
#> Geodetic CRS:  WGS 84
plot(acth7[,4])
```
