# Cities for cartography

This data set is curated to feature cities which can be helpful for
contextualizing locations in a STZ map. It is sourced from
https://simplemaps.com/data/us-cities, and subst in a script available
in the raw-data folder 'EssentialCities.R'.

## Format

A data frame/tibble/sf with 2 columns

- City:

  Full name of city.

- State:

  Abbreviation of State Name, using FIPS code.

- geometry:

  sf geometry column

## Examples

``` r
cities.sf <- sf::st_read(
file.path(
  system.file(package ='eSTZwritR'), 'extdata', 'Carto_cities.gpkg')
)
#> Reading layer `Carto_cities' from data source 
#>   `/home/runner/work/_temp/Library/eSTZwritR/extdata/Carto_cities.gpkg' 
#>   using driver `GPKG'
#> Simple feature collection with 246 features and 3 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -161.7917 ymin: 18.3985 xmax: -66.061 ymax: 64.8353
#> Geodetic CRS:  WGS 84
plot(cities.sf[,1])
```
