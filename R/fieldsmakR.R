#' Ensure that all fields in a shapefile are named correctly, and in the right order.
#'
#' @description Appropriately order the fields of a shapefile and ensure consistent naming of them.
#'
#' @param x an sf/tibble/dataframe containing the spatial data which will be distributed as a final product
#' @param SeedZone a string containing the numeric SeedZone code, if not supplied function will fail.
#' @param ID a string specifying this columns names, If not supplied will create one.
#' @param SZName a string containing a name for the SeedZone column to be used in conversation, such as 'Productivity high, Phenology late' or 'SW midmontane', if not supplied will copy 'SeedZone' column values
#' @param AreaAcres a string containing the name for the column containing an area measurement, if not supplied this value will be calculated using epsg:5070
#' @examples \dontrun{
#' df <- data.frame(
#'   id = 1:10,
#'   gridcode = sample(1:10, replace = FALSE),
#'   zone = sample(LETTERS, 10, replace = FALSE),
#'   bio1_sd = runif(10, 5, 7),
#'   bio8_mean = runif(10, 5, 7)
#' )
#'
#' nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
#'  dplyr::select(geometry) |>
#'  dplyr::slice_head(n = 10) |>
#'  dplyr::bind_cols(df, )
#'
#' ob <- fieldsmakR(nc, SeedZone = 'gridcode')
#'
#' dplyr::select(ob, -zone) # easily remove like so.
#' }
#' @export
fieldsmakR <- function(x, SeedZone, ID, SZName, AreaAcres){

  # ensure geometry has not been abbreviated ala gpkg conventions
  sf::st_geometry(x) <- 'geometry'

  # ensure 'SeedZone' is appropriately named.
  colnames(x)[grep(SeedZone, colnames(x))] <- 'SeedZone'

  x <- dplyr::arrange(x, SeedZone)

  if(missing(ID)){ # create an ID if not already present.
    if(length(grep('^id*', colnames(x))) == 0){
      x <- x |>
        dplyr::mutate(ID = seq_len(nrow(x)), .before = 1)} else {
        colnames(x)[grep('^id*', colnames(x))] <- 'ID'}
  }

  if(missing(SZName)){ # copy these names to this column
    x <- dplyr::mutate(x, SZName = x$SeedZone, .before = 1)
  } else {
    colnames(x)[grep(paste0('^', SZName, '*'), colnames(x))] <- 'SZName'
  }

  # make all of the geometries valid real quick
  x <- sf::st_make_valid(x)

  # calculate the area of each row.
  if(missing(AreaAcres)){
    if(sf::st_crs(x) != 5070){ # convert to projection if necessary
      area <- sf::st_transform(x, 5070) |>
        sf::st_area() |>
        units::set_units('acre') |>
        as.numeric()
    } else {
      area <- sf::st_area(x) |>
        units::set_units('acre') |>
        as.numeric()
    }
  x <- dplyr::bind_cols(x, AreaAcres = area)
  } else{
    colnames(x)[grep(AreaAcres, colnames(x))] <- 'AreaAcres'
  }

  x$AreaAcres <- as.numeric(x$AreaAcres)

  # ensure that the main parts of the BIO column name are complete.
  if(any(grepl('bio', colnames(x), ignore.case = TRUE))){

    # operate only on these columns
    bio_cols <- sf::st_drop_geometry(x[ grep('bio', colnames(x), ignore.case = TRUE) ])
    colnames(bio_cols) <- tolower(colnames(bio_cols)) # so that stats are formatted correctly.

    colnames(bio_cols) <- gsub('bio', 'BIO', colnames(bio_cols), ignore.case = TRUE) # Ensure this portion is uppercase
    colnames(bio_cols) <- gsub('-| ', '_', colnames(bio_cols), ignore.case = TRUE) # Ensure any spacer is an underscore
    colnames(bio_cols) <- gsub('_range|_rng|_r', '_R', colnames(bio_cols), ignore.case = TRUE) # ensure that appropriate statistic abbreviations are used.
    colnames(bio_cols) <- gsub('_average|_avg', '_mean', colnames(bio_cols), ignore.case = TRUE) # ensure that appropriate statistic abbreviations are used.
    colnames(bio_cols) <- gsub('_sd|_std|_SD', '_SD', colnames(bio_cols), ignore.case = TRUE) # ensure that appropriate statistic abbreviations are used.

    x <- dplyr::bind_cols(x[ -grep('bio', colnames(x), ignore.case = TRUE) ], bio_cols)

  }

  # now we will put columns into an order.
  four <- c('ID', 'SeedZone', 'SZName', 'AreaAcres')
  cnames <- colnames(x)[ ! colnames(x) %in% c(four, 'geometry')]

  if(length(cnames)==0){
    # if none of the columns are bio simply return them alphabetically.
    cols <- c(four, 'geometry')
  } else if(length(cnames) == length(grep('^bio', cnames, ignore.case=TRUE))){
    cnames <- cnames[order(as.numeric(gsub('[A-z]', '', cnames)))]
    cols <- c(four, cnames, 'geometry')
  } else if(length(cnames) > length(grep('^bio', cnames, ignore.case=TRUE))){
    # if a mix of columns exist order them by BIO # AND then other columns
    cnames_bio <- cnames[grep('^bio', cnames, ignore.case=TRUE)]
    cnames_bio <- cnames_bio[order(as.numeric(gsub('[A-z]', '', cnames_bio)))]

    cnames_unk <- cnames[ grep('^bio', cnames, invert = TRUE, ignore.case=TRUE) ]
    cnames_unk <- cnames_unk[order(cnames_unk)]
    cnames <- c(cnames_bio, cnames_unk)
    cols <- c(four, cnames, 'geometry')
    cnames_unk <- paste(cnames_unk, collapse = ', ')

    message(
      "There is a column(s), `",  cnames_unk, "`, which we can't figure out the purpose of. It will be returned here, but FYI a list of bioclim variables is here: https://www.worldclim.org/data/bioclim.html. ",
      "If you want to remove this/these columns this should do it: `dplyr::select(x, -c(", cnames_unk, "))`")
  }

  x <- dplyr::select(x, dplyr::any_of(cols)) |>
    dplyr::relocate( dplyr::any_of(cols))

}

