# Determine which interior regions the STZ should be marked with

This function helps determine which Interior Regions coincide with the
majority of an empirical seed transfer zone and should be used for
naming the file.

## Usage

``` r
regionCoding(x, n, regions)
```

## Arguments

- x:

  an empirical STZ as vector data.

- n:

  a sample size for determining which interior regions cover the most
  area of the stz defaults to 1000, sizes above a couple thousand seem
  gratuitous.

- regions:

  an sf object of regions to use the names of. If not provided the
  function will read in a default set. Note that the sf object must have
  a column named 'REG_ABB' containing the region abbreviations.

## Value

a list with a vector and a dataframe. The vector lists this component of
the filename, at most two interior regions separated by a '-'. The
dataframe contains a count of the number of randomly drawn points which
intersect interior regions. For areas with near ties we recommend
increasing the sample size argument, `n` which is paseed to to
st:sample.

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

rc <- regionCoding(acth7)
#> although coordinates are longitude/latitude, st_sample assumes that they are
#> planar
rc$SuggestedName # name suggestions
#> [1] "CGB-CPN"
rc$RegionsCovered # number of random points in each DOI region
#>   REG_ABB   n
#> 1     CGB 436
#> 2     CPN 431
#> 3     UCB 132
```
