#' Suggest seed zones names, or at least numeric orders, based on input polygons
#'
#' @description Given a shapefile of output seed transfer zones, with arbitrarily
#' assigned class or zone identifiers (e.g. numeric) this function specifies an
#' order to the zones from 1 to n zones reflecting an increase in humidity. In other
#' words, this function can assign an order to Seed Zones ID's, where drier zones
#' have lower numbers.
#'
#' We have found it very difficult to discuss zones resulting from any PCA type
#' analysis, or incorporating measurements of phenology etc. Further it is very difficult
#' for us to estimate which zone a new population would be in, or notice many trends
#' in the zones at all. This function uses on aridity, as formulated in the Global
#' Aridity Index Version 3, as the ordering variable for zone numbering. For more
#' information on GAI please see https://www.nature.com/articles/s41597-022-01493-1.
#'
#' Results may not always be statistically robust, but hopefully convey some
#' degree of useful information in their order regarding the range of the zones
#' across the species.
#' @param x an sf/tibble/dataframe containing the spatial data which will be distributed as a final product
#' @param SeedZone name of the column containing the provisional SeedZones
#' @param n sample size of points across the entire shapefile for calculating an order, defaults to 2500. Note that this shouldn't
#' exceed the number of raster cells of the products used to generate the stz, or results will be replicated.
#' @param rasta Either a terra::spatrast object or, a character string of either "coarse" or 'cont' - short for contiguous USA.
#'  GAI coarse has been aggregated by a factor of 2 from it's native 1km resolution to 4k, GAI cont is in the native resolution, but only covers the USA and a degree or so of Canada.
#'  If neither of the rasters contained in the package meet your requirements, resubmit the GAI raster.
#' @param ... additional parameters passed onto sf::st_sample
#' @examples
#' acth7 <- sf::st_read(file.path(
#' system.file(package="eSTZwritR"), "extdata", 'ACTH7.gpkg')
#' ) |>
#'   sf::st_make_valid()
#'
#' zoneOrder_suggestions <- orderZones(acth7, SeedZone = zone, n = 1000)
#'
#' zoneOrder_suggestions$Summary
#' zoneOrder_suggestions$Plot
#'
#' acth7
#' zoneOrder_suggestions$Reclassified
#'
#' # if you want to see the extent of the continental raster
#' # note that the Olympic peninsula and BC get so much rain they essentially
#' # swamps the colors of all other areas in plots.
#' cont <- terra::rast(
#'  file.path(
#'     system.file(package="eSTZwritR"), "extdata", 'GAI-cont.tif')
#' )
#' terra::plot(cont)
#' @returns A list containing three components, 'Reclassified' the shapefile which
#' was submitted, with the #' seedzone values over written by the ones resulting from the function.
#' 'Summary' a dataframe containing the original zones, and final zones, as well as the calculated median and the number of samples used to calculate the median.
#' 'Plot' a ggpubr boxplot of the results of a kruskal-wallis test amongst seed zones.
#' @export
orderZones <- function(x, SeedZone, n, rasta, ...){

  SeedZone <- dplyr::enquo(SeedZone)
  if(missing(n)){n <- 2500}
  if(missing(rasta)){rasta <- 'cont'} # if the user supplied a raster use that instead.
  if(typeof(rasta)!='S4'){

    r <- terra::rast(
      file.path(
        system.file(package="eSTZwritR"),  "extdata",
        paste0('GAI-', rasta, '.tif')
        )
      )
  } else {r <- rasta}
  names(r) <- 'GAI' # ensure naming of raster is correct.

  # We generate the requested number of points, and then intersect them with
  # the STZ to determine which STZ they are associated with. After extracting
  # the aridity values from the raster, we can then determine which zones are more
  # arid than others.
  pts <- sf::st_sample(x, size = n, ...) |>
    sf::st_as_sf() |>
    sf::st_transform(terra::crs(r))

  pts <- sf::st_intersection(pts, x) |>
    sf::st_transform(terra::crs(r))

  pts <- terra::extract(r, pts, bind = TRUE, na.rm = TRUE, xy = TRUE) |>
    sf::st_as_sf() |>
    # ensure that no points are replicated by virtue of being in the same raster cell.
    dplyr::distinct(x, y, .keep_all = TRUE) |>
    dplyr::select(-x, -y) |>
    # Stored as integer in file, has 4 decimals places.
    dplyr::mutate(GAI = GAI/10000)

  # Here we simple determine an order of aridity to each group based on it's
  # median value of aridity. We will begin to create an output object for curious
  # users who may want to better understand the sample size for each group. #
  ZoneOrder <- pts |> # using the median, create an order for each seed zone
    dplyr::group_by(!!SeedZone) |> # more arid areas have a lower order.
    sf::st_drop_geometry() |>
    dplyr::summarise(
      MedianGAI = stats::median(GAI),
      n = dplyr::n()
    ) |>
    dplyr::arrange(MedianGAI) |>
    dplyr::mutate(
      SuggestedOrder = 1:dplyr::n(), .after = 1,
      !!SeedZone := as.numeric(!!SeedZone),
      Zones_fct = factor(!!SeedZone, levels = 1:dplyr::n())
    )

  # The seed zones, ordered by median aridity index, are now applied to the original
  # random points we extracted raster values too. This will allow for easy comparisons
  # of the different STZs to one another, i.e. we can order the groups in a plot.
  pts <- dplyr::mutate(pts, !!SeedZone := factor(!!SeedZone, levels = ZoneOrder$Zones_fct))

  # some products have many zones proposed, RColorBrewer will be hoity-toity if the
  # number of colors requested from it exceeds it's recommended number of colors.
  # this is associated with us essentially transforming a truly continuous color ramp
  # to a discrete one for visualizing groups in the plots below - not a suggested
  # practice for data vis, but our groups are now cut from an aridity gradient so...
  getPalette = grDevices::colorRampPalette(
    RColorBrewer::brewer.pal(
      9, "RdYlGn")
  )

  # create a simple plot to show the analysts how the zones were ordered, and whether
  # there was good evidence of a difference between any of them in the first place!
  p <- ggpubr::ggboxplot(
    pts,
    x = "zone",
    y = "GAI",
    notch = TRUE,
    color = "zone",
    palette = getPalette(length(levels(pts$zone))),
    outlier.alpha = 0.4
  ) +
    # Add global p-value, unfortunately we cannot change from alpha at 0.05
    # i would like to bump it to 0.9 - a 'compromise' between academia and the
    # alpha 0.2 of land management.
    ggpubr::stat_compare_means(
      method = "kruskal",
      label.y = 0.01,
      label.x = 1.5,
    ) +
    # determine which groups have strong evidence of have different central
    # tendencies, we use the *** notation here, which is a compromise because
    # so many p-values become a rounding mess, and no one wants sci notation on plots
    ggpubr::stat_compare_means(
      label = "p.signif",
      method = "t.test",
      ref.group = ".all."
    ) +
    ggplot2::labs( # specify what we are up to.
      title = 'Empirical STZs ordered by Global Aridity Index (GAI)',
      y = 'Global Aridity Index',
      x = 'Zone'
    ) +

    # nasty big legend associated with the groups is created, unnecessary for boxplot
    # and takes up a lot of real estate.
    ggplot2::guides(color="none") +
    ggplot2::theme(
      axis.line.y = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_blank())

  # return the same input item, but with the original zones overwritten.
  rcl <- dplyr::left_join(
    x,
    dplyr::select(ZoneOrder, !!SeedZone, SuggestedOrder)) |>
    dplyr::select(-!!SeedZone, !!SeedZone := SuggestedOrder)

  return(
    list(
      Reclassified = rcl,
      Summary = ZoneOrder,
      Plot = p
    )
  )

}
