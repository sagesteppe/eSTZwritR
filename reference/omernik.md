# Omernik level 3 ecoregions of the USA

This data set contains the, highly simplified, level 3 ecoregions for
the USA. These data are simplified to save space, and for use with
cartographic, not for analytical purposes. They are imported directly
and silently by the `mapmaker` function to contextualize eSTZ border.
These data were sourced from the United States Geological Survey (usgs)
<https://www.sciencebase.gov/catalog/item/55c77f7be4b08400b1fd82d4>

## Usage

``` r
omernik
```

## Format

A data frame/tibble/sf with 3 rows and 2 columns:

- US_L3CODE:

  Ecoregion code

- US_L3NAME:

  Full ecoregion name

- geometry:

  sf geometry column

## Examples

``` r
plot(omernik[,1])
```
