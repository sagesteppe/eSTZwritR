# Create a directory and write out all empirical stz data

Create a directory following standard conventions to ensure appropriate
placement of subdirectories and naming conventions.

## Usage

``` r
dirmakR(outpath, sci_name, x, nrcs_code, regioncode, overwrite, estz_type)
```

## Arguments

- outpath:

  the directory folder where the final products will be placed. Note
  there is no need to create an independent folder to hold them, this
  will be included in the product.

- sci_name:

  the scientific name of the taxon

- x:

  Vector data product.

- nrcs_code:

  from https://plants.usda.gov/

- regioncode:

  a character vector string of the name for this or, the output from
  `regioncoding`

- overwrite:

  whether to overwrite the existing directory (if it already exists)

- estz_type:

  one of 'lg' for landscape genetics (or genetic), 'cg' for common
  garden, or 'cm' for climate matched. If multiple approaches choose the
  most robust method, e.g. 'cg' \> 'lg' \> 'cm'

## Examples

``` r
if (FALSE) { # \dontrun{
acth7 <- sf::st_read(file.path(
  system.file(package="eSTZwritR"), "extdata", 'ACTH7.gpkg')
)
dirmakR('.',
  'Eriocoma thurberiana',
   acth7,
   nrcs_code = 'ACHT7',
   regioncode =  'CGB-CPN',
   estz_type = 'cg'
   )
} # }
```
