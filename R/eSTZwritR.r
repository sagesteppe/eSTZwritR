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
