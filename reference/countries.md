# Borders of three North American nations

This data set contains the borders of three North American countries. It
is used within the `mapmaker` function to showcase the edges of both
landmasses and where the borders of the United States end. These data
are subsetted from the 'spData' r package.

## Usage

``` r
countries
```

## Format

A data frame/tibble/sf with 3 rows and 2 columns:

- name_long:

  Country name

- geom:

  sf geometry column

## Examples

``` r
plot(countries)
```
