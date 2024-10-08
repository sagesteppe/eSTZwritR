#' mapmakR
#' Create standardized maps for empirical seed transfer zones
#' @param x the vector (e.g. shapefile) or raster dataset to plot, note vector data will be coerced
#' to raster before plotting. 
#' @param species character string, the name of the species which is being mapped. 
#' @param outdir a directory to save the map to. Defaults to the current working directory. 
#' @param ecoregions Boolean, whether to draw ecoregions or not. Defaults to TRUE
#' @param landscape boolean, whether to draw the map in a landscape orientation or not. Defaults to TRUE
#' @param caption text for a caption, it's best to mention any published product related to the data set. 
#' Defaults to omitting any caption
#' @param filetype defaults to 'pdf' for saving a pdf page for distribution with data, 
#' but 'png' (or any other format supported by ?ggsave) can be used to create 
#' a map for embedding in a publication or poster. 
mapmakR <- function(x, species, outdir, ecoregions, landscape, caption, filetype){ 
  
  if(missing(species))(stop('Species Name Not supplied.')) 
  if(missing(outdir)){outdir = getwd()} 
  if(missing(caption)){caption = NULL} 
  if(missing(landscape)){landscape = TRUE} 
  if(missing(filetype)){filetype = 'pdf'} 
  fname <- paste0(file.path(outdir, gsub(' ', '_', species)), '_STZmap.', filetype) 
  
  # Buffer the map so that the species only doesn't occupy the entire region. 
  extent <- buffeR(x) 
  
  # ggplot does the cropping to an extent, but we'll manually specify the borders
  # and what data we want here. 
  countries <- spData::world |> 
    dplyr::filter(iso_a2 %in% c('CA', 'US', 'MX')) |> 
    dplyr::select(name_long) |> 
    sf::st_transform(sf::st_crs(extent)) 
  countries <- sf::st_intersection(sf::st_as_sfc(extent), countries) 
  
  states <- tigris::states(cb = TRUE) |> 
    sf::st_transform(5070) 
  states <- sf::st_intersection(sf::st_as_sfc(extent), states) 
  
  omernik <- sf::st_intersection(sf::st_as_sfc(extent), omernik) 
   
  p <- ggplot() + 
    ggplot2::geom_sf(data = x, aes(fill = factor(zone)), color = NA, inherit.aes = TRUE) + 
    ggplot2::geom_sf(data = states, fill = NA, lwd = 0.25, color = 'black', alpha = 0.5) + 
    ggplot2::geom_sf(data = omernik, fill = NA, lty = 3, color = 'grey30') + 
    ggplot2::geom_sf(data = countries, fill = NA, lwd = 1, color = 'black') + 
    ggplot2::coord_sf(
      xlim = extent[c(1,3)], 
      ylim = extent[c(2,4)], 
      expand = F) + 
    
    ggplot2::labs(x = NULL, y = NULL, fill = 'Zone', 
         caption = caption,
         title = paste0('*', species, '*'), 
         subtitle = 'Seed Transfer Zones') +
    ggplot2::theme(
      plot.title = ggtext::element_markdown(hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5),
      legend.title = element_text(hjust = 0.5), 
      legend.position = "bottom"
      ) + 
    
    ggspatial::annotation_scale(location = "br", width_hint = 0.25) +
    ggspatial::annotation_north_arrow(location = "br", which_north = "true", 
                           pad_x = unit(0.25, "in"), pad_y = unit(0.25, "in"), 
                           height = unit(0.35, "in"), width = unit(0.35, "in")) 
  
  if(landscape == TRUE){
    ggsave(filename = fname,
           plot = p, dpi = 300, height = 8.5, width = 11, units = 'in')
  } else {
    ggsave(filename = fname, 
           plot = p, dpi = 300, height = 11, width = 8.5, units = 'in')
  }
  message('File saved to: ', fname)
  
} 
