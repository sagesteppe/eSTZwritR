#' Determine which interior regions the STZ should be marked with
#'
#' @description This function helps determine which Interior Regions coincide with the majority
#' of an empirical seed transfer zone and should be used for naming the file.
#' @param x an empirical STZ as vector data.
#' @param n a sample size for determining which interior regions cover the most area of the stz
#' defaults to 1000, sizes above a couple thousand seem gratuitous.
#' @examples
#' acth7 <- sf::st_read(file.path(
#'   system.file(package="eSTZwritR"), "extdata", 'ACTH7.gpkg')
#' )
#'
#' rc <- regionCoding(acth7)
#' rc$SuggestedName # name suggestions
#' rc$RegionsCovered # number of random points in each DOI region
#'
#' @return a list with a vector and a dataframe. The vector lists this component of the filename, at most
#' two interior regions separated by a '-'.
#' The dataframe contains a count of the number of randomly drawn points which intersect
#' interior regions. For areas with near ties we recommend increasing the sample size argument, `n` which is paseed to
#'  to st:sample.
#' @export
regionCoding <- function(x, n){

  if(missing(n)){n <- 1000}

  regions <- sf::st_read(
    file.path(
      system.file(package="eSTZwritR"),  "extdata", 'regions.gpkg'
    ), quiet = TRUE
  )

  sf::st_agr(regions) <- 'constant';  sf::st_agr(x) <- 'constant'
  pts <- sf::st_sample(x, size = n, type = 'regular') |>
    sf::st_as_sf() |>
    sf::st_set_crs(sf::st_crs(x)) |>
    sf::st_transform(sf::st_crs(regions)) |>
    sf::st_intersection(regions) |>
    sf::st_drop_geometry() |>
    dplyr::count(REG_ABB) |>
    dplyr::arrange(-n)

  suggested_name <- pts |>
    dplyr::slice_head(n = 2) |>
    dplyr::pull(REG_ABB) |>
    paste0(collapse = '-')

  return(
    list(
      'SuggestedName' = suggested_name,
      'RegionsCovered' = pts
      )
    )
}



