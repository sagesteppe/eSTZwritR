#' Borders of three North American nations
#'
#' This data set contains the borders of three North American countries.
#' It is used within the `mapmaker` function to showcase the edges of both landmasses and where the
#' borders of the United States end. These data are subsetted from the 'spData' r package.
#'
#' @format A data frame/tibble/sf with 3 rows and 2 columns:
#' \describe{
#'   \item{name_long}{Country name}
#'   \item{geom}{sf geometry column }
#' }
#' @examples
#' plot(countries)
"countries"

#' Omernik level 3 ecoregions of the USA
#'
#' This data set contains the, highly simplified, level 3 ecoregions for the USA.
#' These data are simplified to save space, and for use with cartographic, not for analytical purposes.
#' They are imported directly and silently by the `mapmaker` function to contextualize eSTZ border.
#' These data were sourced from the United States Geological Survey (usgs) \url{https://www.sciencebase.gov/catalog/item/55c77f7be4b08400b1fd82d4}
#'
#' @format A data frame/tibble/sf with 3 rows and 2 columns:
#' \describe{
#'   \item{US_L3CODE}{Ecoregion code}
#'   \item{US_L3NAME}{Full ecoregion name}
#'   \item{geometry}{sf geometry column}
#' }
#' @examples
#' plot(omernik[,1])
"omernik"

#' Unified interior region boundaries
#'
#' This data set contains the, slightly simplified, 12 department of interior regions.
#' These data are simplified to save disk space, and for use with cartographic not for purposes of analysis, except for region coding.
#' They are imported directly and silently by the `regionCoding` function to determine which geographic areas to append to a file name.
#' These data are sourced from the US Department of Interior (DOI) \url{https://www.doi.gov/employees/reorg/unified-regional-boundaries}.
#' However, the 'REB_ABB' variable, which is ultimately used by eSTZwritR, is derived here and is not an officially sanctioned abbreviation by the USDOI.
#' @name regions
#' @format A data frame/tibble/sf with 3 rows and 2 columns:
#' \describe{
#'   \item{REG_NUM}{Region number}
#'   \item{REG_NAME}{Region name}
#'   \item{REG_ABB}{Unofficial 2-3-letter region abbreviation}
#'   \item{geometry}{sf geometry column}
#' }
#' @examples
#' regions <- sf::st_read(
#' file.path(
#'    system.file(package="eSTZwritR"),  "extdata", 'regions.gpkg'
#'  )
#' )
#' plot(regions[,1]) # those aren't errors - they are some far flung pacific islands.
#' plot(regions[1:10,1]) # more continental of a focus.
NULL

#' Cities for cartography
#'
#' This data set is curated to feature cities which can be helpful for contextualizing locations in a STZ map.
#' It is sourced from https://simplemaps.com/data/us-cities, and subst in a script available in the raw-data folder 'EssentialCities.R'.
#' @name Carto_cities
#' @format A data frame/tibble/sf with 2 columns
#' \describe{
#'   \item{City}{Full name of city.}
#'   \item{State}{Abbreviation of State Name, using FIPS code.}
#'   \item{geometry}{sf geometry column}
#' }
#' @examples
#' cities.sf <- sf::st_read(
#' file.path(
#'   system.file(package ='eSTZwritR'), 'extdata', 'Carto_cities.gpkg')
#' )
#' plot(cities.sf[,1])
NULL

#' An empirical seed transfer zone
#'
#' This data set is from Johnson et al. 2017, and slightly modified by us.
#' It is an eSTZ of Eriocoma thurberiana.
#' Johnson, R. C., E. A. Leger, and Ken Vance-Borland. "Genecology of Thurber’s Needlegrass (Achnatherum thurberianum \[Piper\] Barkworth) in the Western United States." Rangeland Ecology & Management 70.4 (2017): 509-517.
#' @name acth7
#' @format A data frame/tibble/sf with 2 columns
#' \describe{
#'   \item{ID}{A unique ID for each each polygon, note this includes gaps in the numbering. }
#'   \item{GRIDCODE}{From an ESRI raster, the classification output used during creating the product. }
#'   \item{area_ha}{From ESRI calulcated area of each polygon.}
#'   \item{zone}{STZ defined by the authors from the GRIDCODE.}
#'   \item{geometry}{sf geometry column}
#' }
#' @examples
#' acth7 <- sf::st_read(file.path(
#'    system.file(package="eSTZwritR"), "extdata", 'ACTH7.gpkg')
#' )
#' plot(acth7[,4])
NULL

#' A raster of Global Aridity Index version 3
#'
#' This data set is from Zomer et al. 2022, and modified by sub-setting to most US territories, and making more coarse (factor of 2).
#' Zomer, Robert J., Jianchu Xu, and Antonio Trabucco. "Version 3 of the global aridity index and potential evapotranspiration database." Scientific Data 9.1 (2022): 409.
#' @name GAI-coarse
#' @format A raster data set
#' \describe{
#'   \item{GAI}{GAI stored as an integer, needs divided by 10000 to receover decimal places.  }
#' }
#' @examples
#' r <- terra::rast(
#' file.path(
#'    system.file(package="eSTZwritR"),  "extdata", 'GAI-coarse.tif'
#'  )
#' )
#' terra::plot(r/10000, col = terra::map.pal('ryg'))
#' # rainforests swamp the palette!
#' terra::plot(sqrt(r/10000), col = terra::map.pal('ryg'))
#' # better visualization of mid points
#' terra::plot(log(r/10000), col = terra::map.pal('ryg'))
#'  # better vis of low end
NULL


#' A raster of Global Aridity Index version 3
#'
#' This data set is from Zomer et al. 2022, and modified by sub-setting to the contiguous USA.
#' Zomer, Robert J., Jianchu Xu, and Antonio Trabucco. "Version 3 of the global aridity index and potential evapotranspiration database." Scientific Data 9.1 (2022): 409.
#' @name GAI-cont
#' @format A raster data set
#' \describe{
#'   \item{GAI}{GAI stored as an integer, needs divided by 10000 to receover decimal places.  }
#' }
#' @examples
#' r <- terra::rast(
#'  file.path(
#'    system.file(package="eSTZwritR"),  "extdata", 'GAI-cont.tif'
#'  )
#' )
#' terra::plot(r/10000, col = terra::map.pal('ryg'))
#' # rainforests swamp the palette!
#' terra::plot(sqrt(r/10000), col = terra::map.pal('ryg'))
#'  # better visualization of mid points
#' terra::plot(log(r/10000), col = terra::map.pal('ryg'))
#' # better vis of low end
NULL
