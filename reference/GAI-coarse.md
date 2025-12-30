# A raster of Global Aridity Index version 3

This data set is from Zomer et al. 2022, and modified by sub-setting to
most US territories, and making more coarse (factor of 2). Zomer, Robert
J., Jianchu Xu, and Antonio Trabucco. "Version 3 of the global aridity
index and potential evapotranspiration database." Scientific Data 9.1
(2022): 409.

## Format

A raster data set

- GAI:

  GAI stored as an integer, needs divided by 10000 to receover decimal
  places.

## Examples

``` r
r <- terra::rast(
file.path(
   system.file(package="eSTZwritR"),  "extdata", 'GAI-coarse.tif'
 )
)
terra::plot(r/10000, col = terra::map.pal('ryg'))

# rainforests swamp the palette!
terra::plot(sqrt(r/10000), col = terra::map.pal('ryg'))

# better visualization of mid points
terra::plot(log(r/10000), col = terra::map.pal('ryg'))

 # better vis of low end
```
