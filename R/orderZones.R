#' Suggest seed zones names, or at least numeric orders, based on input polygons
#' 
#' This function seeks to make STZ more simple to convey, or at least visualize. Rather than using seed zone names 
#' which relate to growth measurements, phenological responses, or combinations thereof, or zones from PCA axis we bastardize
#' the results of these analyses to two major components which humans think about extensively. Mean annual temperature, and
#' mean annual precipitation. By rescaling these two variables together we propose intuitively simple zones that follow a gradient from
#' hot and dry to cool and moist. 
#' @param x an sf/tibble/dataframe containing the spatial data which will be distributed as a final product
#' @param SeedZone name of the column containing the provisional SeedZones
#' @param n sample size of points across the entire shapefile for calculating an order, defaults to 2500. Note that this shouldn't
#' exceed the number of raster cells of the products used to generate the stz, or results will be replicated.
#' @param plot boolean, whether to create a plot of the results or not. 
#' @param ... additional parameters passed onto sf::st_sample
#' @examples
#'
#' @export 
orderZones <- function(x, SeedZone, n, ...){
  
  if(missing(n)){n <- 2500}
  precip <- terra::rast(system.file("extdata", "/PRISM_ann_ppt.tif", package="eSTZwritR"))
  temp <- terra::rast(system.file("extdata", "/PRISM_ann_temp.tif", package="eSTZwritR"))
  names(precip) <- 'AnnualPrecipitation' ; names(temp) <- 'MeanAnnualTemp' ; 

  x <- dplyr::select(x, SeedZone = SeedZone)
  pts <- sf::st_sample(x, size = n, ...) |>
    sf::st_as_sf() 
  
  pts <- sf::st_intersection(x, pts) |> 
    sf::st_transform(terra::crs(precip))
  
  pts <- terra::extract(precip, terra::vect(pts), bind = TRUE, na.rm = TRUE)
  pts <- terra::extract(temp, pts, bind = TRUE, na.rm = TRUE)|>
    sf::st_as_sf()
  
  values <- data.frame(
    Zone = x$SeedZone,
    AnnualPrecipitation = scales::rescale(pts$AnnualPrecipitation),
    MeanAnnualTemp = scales::rescale(pts$MeanAnnualTemp)
  ) |>
    dplyr::group_by(Zone)|>
    dplyr::summarise(
      meanAP = mean(AnnualPrecipitation),
      meanMAT = mean(MeanAnnualTemp)
    )
  
  return(values)
  
}

nc <- sf::st_read(system.file("shape/nc.shp", package="sf")) |>
  dplyr::slice_head(n = 10) 

pts <- orderZones(nc, SeedZone = 'NAME', n = 100)


SZplot <- ggplot2::ggplot() + 
  ggplot2::geom_point(data = pts, 
                      ggplot2::aes(
                        x = AnnualPrecipitation, 
                        y = MeanAnnualTemp, 
                        color = SeedZone)
                      ) + 
  ggplot2::labs(
    title = 'Relationship between Temperature and Precipitation across Seed Zones',
    color = 'Seed Zone',
    caption = 'Source: PRISM 1990-2020 climate normals') + 
  ggplot2::theme_classic() + 
  
  ggplot2::scale_y_continuous(
    'Mean Annual Temperature (C\u00B0)',
    sec.axis = sec_axis( ~ (. * 9/5) + 32, name = "MAT (F\u00B0)")
  ) + 
  ggplot2::scale_x_continuous(
    'Annual Precipitation (mm)',
    sec.axis = sec_axis( ~ . * 0.0393701, name = "AP (inches)")
  )
                     

library(ggplot2) 
