#' Suggest seed zones names, or at least numeric orders, based on input polygons
#'
#' @description This function seeks to make STZ more simple to convey, or at least visualize. Rather than using seed zone names
#' which relate to growth measurements, phenological responses, or combinations thereof, or zones from PCA axis we bastardize
#' the results of these analyses to two major components which humans think about extensively. Mean annual temperature, and
#' mean annual precipitation. By rescaling these two variables together we propose intuitively simple zones that follow a gradient from
#' hot and dry to cool and moist.
#' @param x an sf/tibble/dataframe containing the spatial data which will be distributed as a final product
#' @param SeedZone name of the column containing the provisional SeedZones
#' @param n sample size of points across the entire shapefile for calculating an order, defaults to 2500. Note that this shouldn't
#' exceed the number of raster cells of the products used to generate the stz, or results will be replicated.
#' @rasta Either a terra::spatrast object or, a character string of either "coarse" or 'cont' - short for contiguous USA. GAI coarse has been aggregated by a factor of 2 from it's native 1km resolution to 4k, GAI cont is in the native resolution, but only covers the USA and a degree or so of Canada.
#' @param ... additional parameters passed onto sf::st_sample
#' @examples
#' acth7 <- sf::st_read(file.path(
#'   system.file(package="eSTZwritR"), "inst", "extdata", 'ACTH7.gpkg')
#' )
#'
#' pts <- orderZones(acth7, SeedZone = 'NAME', n = 1500)
#'
#'
#' SZplot <- ggplot2::ggplot() +
#'   ggplot2::geom_point(data = pts,
#'                      ggplot2::aes(
#'                        x = AnnualPrecipitation,
#'                        y = MeanAnnualTemp,
#'                        color = SeedZone)
#'  ) +
#'  ggplot2::labs(
#'    title = 'Relationship between Temperature and Precipitation across Seed Zones',
#'    color = 'Seed Zone',
#'    caption = 'Source: PRISM 1990-2020 climate normals') +
#'  ggplot2::theme_classic() +
#'
#'  ggplot2::scale_y_continuous(
#'    name = 'Mean Annual Temperature (C\u00B0)',
#'    sec.axis = ggplot2::sec_axis( ~ (. * 9/5) + 32, name = "MAT (F\u00B0)")
#'  ) +
#'  ggplot2::scale_x_continuous(
#'    name = 'Annual Precipitation (mm)',
#'    sec.axis = ggplot2::sec_axis( ~ . * 0.0393701, name = "AP (inches)")
#'  )
#'
#' # if you want to see the extent of the continental raster
#' # note that the Olympic peninsula and BC get so much rain they essentially
#' # swamps the colors of all other areas in plots.
#' cont <- terra::rast(
#'  file.path(
#'     system.file(package="eSTZwritR"), "inst", "extdata", 'GAI-cont.tif')
#' )
#' plot(cont)
#' @export
orderZones <- function(x, SeedZone, n, rasta, ...){

  if(missing(n)){n <- 2500}

  if(missing(rasta)){rasta <- 'cont'} # if the user supplied a raster use that instead.
  if(typeof(rasta)!='S4'){

    r <- terra::rast(
      file.path(
        system.file(package="eSTZwritR"), "inst", "extdata",
        paste0('GAI-', rasta, '.tif')
        )
      )
    names(r) <- 'GAI'

  } else {r <- rasta}
  names(r)

  x <- dplyr::select(x, SeedZone = SeedZone)
  pts <- sf::st_sample(x, size = n, ...) |>
    sf::st_as_sf()

  pts <- sf::st_intersection(x, pts) |>
    sf::st_transform(terra::crs(r))

  pts <- terra::extract(r, terra::vect(pts), bind = TRUE, na.rm = TRUE) |>
    sf::st_as_sf()

  values <- data.frame(
    Zone = x$SeedZone,
    AnnualPrecipitation = scales::rescale(pts[[names(r)]]),
  )

  return(values)

}
