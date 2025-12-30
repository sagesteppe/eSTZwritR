# buffR

buffer an input STZ to determine map extents

## Usage

``` r
buffR(x, buf_prcnt)
```

## Arguments

- x:

  an input STZ, as vector or raster data -vector is much preferred for
  speed.

- buf_prcnt:

  the amount of buffering to add to the map, defaults to 0.005 or 0.5%

## Value

a bounding box around the eSTZ product of the specified buffer amount.
