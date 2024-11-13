#' Borders of three North American nations.
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
"countries"


#' Omernik level 3 ecoregions of the USA
#'
#' This data set contains the, slightly simplified, level 3 ecoregions for the USA.
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
"omernik"

#' Unified interior region boundaries
#'
#' This data set contains the, slightly simplified, 12 department of interior regionas.
#' These data are simplified to save space, and for use with cartographic, not for analytical purposes.
#' They are imported directly and silently by the `regionCoding` function to determine which geographic areas to append to a filename.
#' These data are sourced from the US Department of Interior (DOI) \url{https://www.doi.gov/employees/reorg/unified-regional-boundaries}.
#' However, the 'REB_ABB' variable, which is utlimately used by eSTZwritR, is derived here and is not an officially sanctioned abbrevation by the USDOI.
#' @format A data frame/tibble/sf with 3 rows and 2 columns:
#' \describe{
#'   \item{REG_NUM}{Region number}
#'   \item{REG_NAME}{Region name}
#'   \item{REG_ABB}{Unofficial 2-3-letter region abbreviation}
#'   \item{geometry}{sf geometry column}
#' }
"regions"


#' Dataset Carto_cities
#'
#' This data set is curated to feature cities which can be helpful for contextualizing locations in a STZ map.
#' It is sourced from https://simplemaps.com/data/us-cities, and subst in a script available in the raw-data folder 'EssentialCities.R'.
#' @name simplemaps_uscities_basicv1.79
#'
#' @section Carto_cities.gpkg:
#'
#' This data is used in mapmakR().
NULL

#' Dataset ACTH7.gpkg
#'
#' This data set is from Johnson et al. 2017, and slightly modified by us.
#' It is an eSTZ of Eriocoma thurberiana.
#' Johnson, R. C., E. A. Leger, and Ken Vance-Borland. "Genecology of Thurber’s Needlegrass (Achnatherum thurberianum \[Piper\] Barkworth) in the Western United States." Rangeland Ecology & Management 70.4 (2017): 509-517.
#' @name ACTH7
#'
#' @section ACTH7.gpkg:
#'
#' This data is, by default, used in orderZones()
NULL

#' Dataset GAI-coarse
#'
#' This data set is from Zomer et al. 2022, and modified by sub-setting to most US territories, and making more coarse (factor of 2).
#' Zomer, Robert J., Jianchu Xu, and Antonio Trabucco. "Version 3 of the global aridity index and potential evapotranspiration database." Scientific Data 9.1 (2022): 409.
#' @name GAI-coarse
#'
#' @section GAI-coarse.tif:
#'
#' This data is, optionally, used in orderZones()
NULL

#' Dataset GAI-cont
#'
#' This data set is from Zomer et al. 2022, and modified by sub-setting to the contiguous USA.
#' Zomer, Robert J., Jianchu Xu, and Antonio Trabucco. "Version 3 of the global aridity index and potential evapotranspiration database." Scientific Data 9.1 (2022): 409.
#' @name GAI-cont
#'
#' @section GAI-cont.tif:
#'
#' This data is, by default, used in orderZones()
NULL

