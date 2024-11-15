#' Create a directory and write out all empirical stz data
#'
#' @description Create a directory following standard conventions to ensure appropriate
#' placement of subdirectories and naming conventions.
#'
#' @param outpath the directory folder where the final products will be placed. Note there is no need
#' to create an independent folder to hold them, this will be included in the product.
#' @param sci_name the scientific name of the taxon
#' @param x Vector data product.
#' @param nrcs_code from https://plants.usda.gov/
#' @param regioncode a character vector string of the name for this or, the output from `regioncoding`
#' @param overwrite whether to overwrite the existing directory (if it already exists)
#' @param estz_type one of 'lg' for landscape genetics (or genetic), 'cg' for common garden, or 'cm' for climate matched.
#' If multiple approaches choose the most robust method, e.g. 'cg' > 'lg' > 'cm'
#' @examples
#' acth7 <- sf::st_read(file.path(
#'   system.file(package="eSTZwritR"), "extdata", 'ACTH7.gpkg')
#' )
#' dirmakR('.', 'Eriocoma thurberiana', acth7, nrcs_code = 'ACHT7', regioncode =  'CGB-CPN', estz_type = 'cg')
#' @export
dirmakR <- function(outpath, sci_name, x, nrcs_code, regioncode, overwrite, estz_type){

  if(missing(overwrite)){overwrite <- FALSE}
  if(length(regioncode)>1){regioncode <- regioncode[1]}

  node1 <- file.path(outpath,
                     paste0(gsub(' ', '_', sci_name), estz_type, 'STZ'))

  if(dir.exists(node1) & overwrite == FALSE) {
    message(node1, ' was found. If you still need this function to run use the argument `overwrite = TRUE`.')
  } else {

    dir.create(node1) #create all the sub directories
    dir.create(file.path(node1, 'Information'))
    dir.create(file.path(node1, 'Data'))
    dir.create(file.path(node1, 'Data', 'Vector'))
    dir.create(file.path(node1, 'Data', 'Raster'))

    #########              write out the spatial data.                #########
    sf::st_make_valid(x) |> # ensure geometries do not self-intersect.
      sf::st_write(
        paste(file.path(node1, 'Data', 'Vector'), nrcs_code, '_', estz_type, 'STZ.shp')
      )

  #    terra::writeRaster(
  #      paste(
  #        file.path(node1, 'Data', 'Raster'), nrcs_code, '_', estz_type, 'STZ.tif')
  #    )

    }
}
