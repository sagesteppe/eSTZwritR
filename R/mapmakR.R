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
#' @param sci_name Character string, the name of the species which is being mapped.
#' @param save Boolean, whether to save the file or not. Defaults to TRUE.
#' @param outpath Character string, a directory to save the map to. Defaults to the current working directory.
#' @param ecoregions Boolean, whether to draw ecoregions or not. Defaults to TRUE.
#' @param cities Boolean, whether to draw cities or not, Defaults to TRUE.
#' @param city_reduce Character string. One of "Distance", "Population", defaults to 'Distance'. Maps of very large domains (get 10+ western states) feel cluttered if too many cities are added to them.
#' If cities==TRUE and cities > city_reduce_no, then this argument utilizes a method to reduce the number of mapped cities to city_reduce_no.
#'
#' Method "Distance" (the default) will sample 250 regularly spaced grid points and restrict them to the eSTZ surface, and calculate pairwise distances between all points and all cities.
#' Only the city_reduce_no will be retained. Method "Population" will simply keep the largest city_reduce_no cities. It may be a better alternative for showing the map to people from more distal geographic regions.
#' @param city_reduce_no Numeric. Max number of cities to to include on map, defaults to 20.
#' @param landscape Boolean, whether to draw the map in a landscape orientation or not. Defaults to TRUE
#' @param caption Character string, text for a caption. It's best to mention any published product related to the data set.
#' Defaults to omitting any caption, except for the data sources (if omernik and cities are used),
#'  and coordinate reference system information.
#' @param filetype Character string, defaults to 'pdf' for saving a pdf page for distribution with data,
#' @param buf_prcnt The amount to buffer the extent around the focal taxons range by. Defaults to 0.025 oor 2.5%
#' but 'png' (or any other format supported by ?ggsave) can be used to create
#' a map for embedding in a publication or poster.
#' @param SZName Character. The field containing the seed zone, defaults to 'SZName'.
#' @examples
#' library(eSTZwritR)
#' acth7 <- sf::st_read(file.path(
#'   system.file(package="eSTZwritR"), "extdata", 'ACTH7.gpkg')
#' )
#'
#'
#' p <- mapmakR(acth7,
#'  sci_name = 'Eriocoma thurberiana',
#'  save = FALSE,
#'  landscape = FALSE,
#'  ecoregions = TRUE,
#'  cities = TRUE,
#'  SZName = zone,
#'  caption = 'Data from Johnson et al. 2017. https://doi.org/10.1016/j.rama.2017.01.004'
#'  )
#'  plot(p)
#' @returns Writes a PDF (or other specified `filetype`) to disk, and returns the ggplot object to console allowing user to modify it for other purposes.
#' @export
mapmakR <- function(x, sci_name, save, outpath, ecoregions, cities, city_reduce, city_reduce_no, landscape, caption, filetype, buf_prcnt, SZName = SZName){

  if(missing(sci_name))(stop('sci_name Name Not supplied.'))
  if(missing(save)){save <- TRUE}
  if(missing(outpath)){outpath = getwd()}
  if(missing(landscape)){landscape = TRUE}
  if(missing(ecoregions)){ecoregions = TRUE}
  if(missing(filetype)){filetype = 'pdf'}
  if(missing(cities)){cities <- TRUE}
  if(missing(city_reduce)){city_reduce <- 'Distance'}
  if(missing(city_reduce_no)){city_reduce_no <- 20}
  if(missing(buf_prcnt)){buf_prcnt <- 0.025}
  SZName <- dplyr::enquo(SZName)
  fname <- paste0(file.path(outpath, gsub(' ', '_', sci_name)), '_STZmap.', filetype)

  sf::st_agr(x) <- 'constant'
  # Buffer the map so that the species only doesn't occupy the entire region.
  extent <- buffR(x, buf_prcnt)
  if(cities){
    cities.sf <- sf::st_read(
      file.path(
        system.file(package ='eSTZwritR'), 'extdata', 'Carto_cities.gpkg'), quiet = TRUE) |>
        sf::st_transform(sf::st_crs(x))
    sf::st_agr(cities.sf) <- 'constant'
    cities.sf <- sf::st_crop(cities.sf, x)
  }

  if(nrow(cities.sf) > city_reduce_no){
    if(city_reduce=='population'){
      cities.sf <- dplyr::slice_max(cities.sf, order_by = Population, n = city_reduce_no)
    } else if(city_reduce=='Distance'){

      pts <- sf::st_sample(x, size = 250, type = 'regular')|>
        sf::st_set_crs(sf::st_crs(x))|>
        sf::st_as_sf()

        pts <- pts[which(lengths(sf::st_intersects(pts, x)) > 0),]
        cities.sf <- cities.sf[
          order(
           apply(
             sf::st_distance(
               pts, cities.sf),
             MARGIN = 2, mean, na.rm = TRUE)
           )[1:city_reduce_no], ]
    }
  }

  if(ecoregions){
    omernik <- sf::st_transform(omernik, sf::st_crs(x))
    sf::st_agr(omernik) <- 'constant'
  }

  # ggplot does the cropping to an extent, but we'll manually specify the borders
  # and what data we want here.
  countries <- spData::world |>
    dplyr::filter(iso_a2 %in% c('CA', 'US', 'MX')) |>
    dplyr::select(name_long) |>
    sf::st_transform(sf::st_crs(x))

  states <- tigris::states(cb = TRUE, progress_bar = FALSE, year = 2022) |>
    sf::st_transform(sf::st_crs(x))

  x <- dplyr::mutate(x, SZName = forcats::as_factor(!!SZName))
  p <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = countries,
      fill = 'cornsilk',
      color = NA,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_sf(
      data = x,
      ggplot2::aes(fill = SZName),
      color = NA,
      inherit.aes = TRUE) +
    ggplot2::geom_sf(
      data = states,
      fill = 'cornsilk',
      lwd = 0.25,
      color = 'black',
      alpha = 0.5) +

    ggspatial::annotation_scale(location = "br", width_hint = 0.25) +
    ggspatial::annotation_north_arrow(
      location = "br", which_north = "true",
      pad_x = ggplot2::unit(0.25, "in"), pad_y = ggplot2::unit(0.25, "in"),
      height = ggplot2::unit(0.35, "in"), width = ggplot2::unit(0.35, "in")
      )

  caption <- paste0(caption, '. CRS: ', sf::st_crs(x)[[1]])
  states_only <- '\nStates data courtesy of US Census Bureau'
  ecoTcityF <- '. Omernik ecoregions courtesy of US EPA'
  ecoFcityT <- '. Cities courtesy of Simplemaps.com'
  ecoTcityT <- '. Omernik ecoregions courtesy of US EPA. Cities courtesy of Simplemaps.com'
  #determine the correct caption format for the data.
  if(exists('caption')){
    if(ecoregions == TRUE & cities == FALSE){
      caption <- paste0(caption, states_only, ecoTcityF)
      } else if(ecoregions == FALSE & cities == TRUE){
        caption <- paste0(caption, states_only, ecoFcityT)
        } else if(ecoregions == TRUE & cities == TRUE){
          caption <- paste0(caption, states_only, ecoTcityT)
      }
    } else {
    if(ecoregions == TRUE & cities == FALSE){
      caption <- paste0(ecoTcityF)
      } else if(ecoregions == FALSE & cities == TRUE){
        caption <- paste0(states_only, ecoFcityT)
        } else if(ecoregions == TRUE & cities == TRUE){
          caption <- paste0(states_only, ecoTcityT)
        }
    }

  # determine whether to add cities and ecoregions to the plot.
    if(ecoregions == TRUE & cities == FALSE){
      p <- p +
        ggplot2::geom_sf(
          data = omernik,
          fill = NA,
          lty = 3,
          linewidth = 0.5,
          color = 'grey30') +
        ggplot2::labs(caption = caption)

    } else if(ecoregions == FALSE & cities == TRUE){
    p <- p +
      ggplot2::geom_sf(data = cities.sf) +
      suppressWarnings(
        ggrepel::geom_text_repel(
          data = cities.sf,
          ggplot2::aes(label = City, geometry = geom),
          stat = "sf_coordinates")
        ) +
      ggplot2::labs(caption = caption)

    } else if(ecoregions == TRUE & cities == TRUE){
    p <- p +
      ggplot2::geom_sf(
        data = omernik,
        fill = NA,
        lty = 3,
        linewidth = 0.5,
        color = 'grey30') +
      ggplot2::geom_sf(data = cities.sf) +
      suppressWarnings(
        ggrepel::geom_text_repel(
          data = cities.sf,
          ggplot2::aes(label = City, geometry = geom),
          stat = "sf_coordinates")
        ) +
      ggplot2::labs(caption = caption)

    } else {
    p <- p +
      ggplot2::labs(caption = caption)
    }

  #  add on style elements which would be overwritten by the above code.
  p <- p + ggplot2::coord_sf(
    xlim = extent[c(1,3)],
    ylim = extent[c(2,4)],
    default_crs = sf::st_crs(4326),
    expand = F
  ) +
    ggplot2::labs(
      x = NULL, y = NULL, fill = 'Transfer\nZone',
      title = paste0('*', sci_name, '*'),
      subtitle = 'Seed Transfer Zones') +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = "aliceblue"),
      plot.title = ggtext::element_markdown(hjust = 0.5),
      plot.subtitle = ggplot2::element_text(hjust = 0.5),
      legend.title = ggplot2::element_text(hjust = 0.5)
    )

  # Determine where to put the legend. Added to the size of Portrait Plots,
  # the base of landscape Plots.
  if(landscape == TRUE){
    p <- p + ggplot2::theme(legend.position='right')
  } else if (landscape == FALSE){
    p <- p + ggplot2::theme(
      legend.position='bottom',
      legend.justification = "left",
    )
  }

  # If there are tons of seed zones, then increase the number of columns, this only
  # seems to be an issue with > 30 categories, where ggplot maxes out default columns
  # to 5. When this happens the map is shrunk to make up for the vertical space
  # consumed by the legend.
  lvls <- length(unique(x[['SZName']]))
  if(lvls>30){
    p <- p + ggplot2::guides(fill = ggplot2::guide_legend(ncol = round(lvls/5)))
  }

# save file to location
  if(save==TRUE){
    if(landscape == TRUE){
      ggplot2::ggsave(filename = fname,
             plot = p, dpi = 300, height = 8.5, width = 11, units = 'in')
    } else if (landscape == FALSE){
      ggplot2::ggsave(filename = fname,
             plot = p, dpi = 300, height = 11, width = 8.5, units = 'in')
    }
    message('File saved to: ', fname)
  }

  return(p) # also return the plot to user.

}

