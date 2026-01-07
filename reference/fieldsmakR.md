# Ensure that all fields in a shapefile are named correctly, and in the right order.

Appropriately order the fields of a shapefile and ensure consistent
naming of them.

## Usage

``` r
fieldsmakR(x, SeedZone, ID, SZName, AreaAcres)
```

## Arguments

- x:

  an sf/tibble/dataframe containing the spatial data which will be
  distributed as a final product

- SeedZone:

  Character. Column name containing the numeric SeedZone code, if not
  supplied function will fail.

- ID:

  Character. Columm name specifying this columns names, If not supplied
  will create one.

- SZName:

  Character. Column name containing a name for the SeedZone column to be
  used in conversation, such as 'Productivity high, Phenology late' or
  'SW midmontane', if not supplied will copy 'SeedZone' column values

- AreaAcres:

  Chacter. Column name containing the name for the column containing an
  area measurement, if not supplied this value will be calculated using
  epsg:5070

## Examples

``` r
if (FALSE) { # \dontrun{
df <- data.frame(
  id = 1:10,
  gridcode = sample(1:10, replace = FALSE),
  zone = sample(LETTERS, 10, replace = FALSE),
  bio1_sd = runif(10, 5, 7),
  bio8_mean = runif(10, 5, 7)
)

nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
 dplyr::select(geometry) |>
 dplyr::slice_head(n = 10) |>
 dplyr::bind_cols(df, )

ob <- fieldsmakR(nc, SeedZone = 'gridcode')

dplyr::select(ob, -zone) # easily remove like so.
} # }
```
