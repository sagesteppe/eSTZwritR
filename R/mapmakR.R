#' Create standardized maps for empirical seed transfer zones
#'
#' @description Create a full page PDF map for distributing with the eSTZ for quick refernce by users.
#' The function will also return the map as a ggplot object if you want to make further modifications to it.
#' These maps are intended for being seen in a large format size, and may not be suitable for including in a manuscript or publication, outsize the appendeix or online references.
#' If you like components of the map, and want to try and make them for a smaller format, you can rip out the source code and go from there; don't worry this map is very simple so there isn't much to figure out there.
#' You can visualize source code by typing either: `mapmakR` (without a function argument) into the R console, or in a more intuitive format on Github at: https://github.com/sagesteppe/eSTZwritR/blob/main/R/mapmakR.R .
#'
#' @param x the vector (e.g. shapefile) or raster dataset to plot, note vector data will be coerced
#' to raster before plotting.
#' @param species Character string, the name of the species which is being mapped.
#' @param save Boolean, whether to save the file or not. Defaults to TRUE.
#' @param outdir Character string, a directory to save the map to. Defaults to the current working directory.
#' @param ecoregions Boolean, whether to draw ecoregions or not. Defaults to TRUE.
#' @param cities Boolean, whether to draw cities or not, Defaults to TRUE.
#' @param landscape Boolean, whether to draw the map in a landscape orientation or not. Defaults to TRUE
#' @param caption Character string, text for a caption. It's best to mention any published product related to the data set.
#' Defaults to omitting any caption, except for the data sources (if omernik and cities are used),
#'  and coordinate reference system information.
#' @param filetype Character string, defaults to 'pdf' for saving a pdf page for distribution with data,
#' but 'png' (or any other format supported by ?ggsave) can be used to create
#' a map for embedding in a publication or poster.
#' @examples
#' acth7 <- sf::st_read(file.path(
#'   system.file(package="eSTZwritR"), "extdata", 'ACTH7.gpkg')
#' )
#'
#' mapmakR(acth7,
#'  species = 'Eriocoma thurberiana',
#'  save = FALSE,
#'  ecoregions = TRUE,
#'  cities = TRUE,
#'  caption = 'Johnson et al. 2017')
#' @returns Writes a PDF (or other specified `filetype`) to disk, and returns the ggplot object to console allowing user to modify it for other purposes.
#' @export
mapmakR <- function(x, species, save, outdir, ecoregions, cities, landscape, caption, filetype){

  if(missing(species))(stop('Species Name Not supplied.'))
  if(missing(save)){save <- TRUE}
  if(missing(outdir)){outdir = getwd()}
  if(missing(landscape)){landscape = TRUE}
  if(missing(ecoregions)){ecoregions = TRUE}
  if(missing(filetype)){filetype = 'pdf'}
  fname <- paste0(file.path(outdir, gsub(' ', '_', species)), '_STZmap.', filetype)

  if(missing(cities)){cities <- TRUE}
  if(cities == TRUE){
    cities.sf <- sf::st_read(
      file.path(
        system.file(package ='eSTZwritR'), 'extdata', 'Carto_cities.gpkg')
    )
    }

  # Buffer the map so that the species only doesn't occupy the entire region.
  extent <- buffR(x)

  # ggplot does the cropping to an extent, but we'll manually specify the borders
  # and what data we want here.
  countries <- spData::world |>
    dplyr::filter(iso_a2 %in% c('CA', 'US', 'MX')) |>
    dplyr::select(name_long) |>
    sf::st_transform(sf::st_crs(extent))
  countries <- sf::st_intersection(sf::st_as_sfc(extent), countries)

  states <- tigris::states(cb = TRUE, progress_bar = FALSE) |>
    sf::st_transform(5070)
  states <- sf::st_intersection(sf::st_as_sfc(extent), states)

  omernik <- sf::st_intersection(sf::st_as_sfc(extent), omernik)

  p <- ggplot() +
    ggplot2::geom_sf(data = x, aes(fill = factor(zone)), color = NA, inherit.aes = TRUE) +
    ggplot2::geom_sf(data = states, fill = NA, lwd = 0.25, color = 'black', alpha = 0.5) +
    ggplot2::geom_sf(data = countries, fill = NA, lwd = 1, color = 'black') +
    ggplot2::coord_sf(
      xlim = extent[c(1,3)],
      ylim = extent[c(2,4)],
      expand = F) +

    ggplot2::labs(x = NULL, y = NULL, fill = 'Zone',
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

  #determine the correct caption format for the data.
  if(exists(caption)){
    if(ecoregions == TRUE & cities == FALSE){
      caption <- paste0(caption, '\nOmernik Ecoregions data courtesy of US EPA.')
      } else if(ecoregions == FALSE & cities == TRUE){
        caption <- paste0(caption, '\nCities data courtesy of Simplemaps.com')
        } else if(ecoregions == TRUE & cities == TRUE){
          caption <- paste0(caption, '\nOmernik Ecoregions data courtesy of US EPA.\nCities data courtesy of Simplemaps.com')
      }
    } else {
    if(ecoregions == TRUE & cities == FALSE){
      caption <- paste0('Omernik Ecoregions data courtesy of US EPA.')
      } else if(ecoregions == FALSE & cities == TRUE){
        caption <- paste0('Cities data courtesy of Simplemaps.com')
        } else if(ecoregions == TRUE & cities == TRUE){
          caption <- paste0('Omernik Ecoregions data courtesy of US EPA.\nCities data courtesy of Simplemaps.com')
        }
  }

  # determine whether to add cities and ecoregions to the plot.
    if(ecoregions == TRUE & cities == FALSE){
      p <- p +
        ggplot2::geom_sf(data = omernik, fill = NA, lty = 3, color = 'grey30') +
        ggplot2::labs(caption)

    } else if(ecoregions == FALSE & cities == TRUE){
    p <- p +
      ggplot2::geom_sf(data = cities.sf) +
      ggplot2::geom_sf_text(data = cities.sf, aes(label = City)) +
      ggplot2::labs(caption)

    } else if(ecoregions == TRUE & cities == TRUE){
    p <- p +
      ggplot2::geom_sf(data = omernik, fill = NA, lty = 3, color = 'grey30') +
      ggplot2::geom_sf(data = cities.sf) +
      ggplot2::geom_sf_text(data = cities.sf, aes(label = City)) +
      ggplot2::labs(caption)

    } else {
    p <- p +
      ggplot2::labs(caption)
  }

# save file to location
  if(save==TRUE){
    if(landscape == TRUE){
      ggsave(filename = fname,
             plot = p, dpi = 300, height = 8.5, width = 11, units = 'in')
    } else {
      ggsave(filename = fname,
             plot = p, dpi = 300, height = 11, width = 8.5, units = 'in')
    }
    message('File saved to: ', fname)
  }

  return(p)

}
