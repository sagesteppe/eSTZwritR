% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mapmakR.R
\name{mapmakR}
\alias{mapmakR}
\title{Create standardized maps for empirical seed transfer zones}
\usage{
mapmakR(
  x,
  species,
  save,
  outdir,
  ecoregions,
  cities,
  landscape,
  caption,
  filetype,
  buf_prcnt,
  SZName
)
}
\arguments{
\item{x}{the vector (e.g. shapefile) or raster dataset to plot, note vector data will be coerced
to raster before plotting.}

\item{species}{Character string, the name of the species which is being mapped.}

\item{save}{Boolean, whether to save the file or not. Defaults to TRUE.}

\item{outdir}{Character string, a directory to save the map to. Defaults to the current working directory.}

\item{ecoregions}{Boolean, whether to draw ecoregions or not. Defaults to TRUE.}

\item{cities}{Boolean, whether to draw cities or not, Defaults to TRUE.}

\item{landscape}{Boolean, whether to draw the map in a landscape orientation or not. Defaults to TRUE}

\item{caption}{Character string, text for a caption. It's best to mention any published product related to the data set.
Defaults to omitting any caption, except for the data sources (if omernik and cities are used),
and coordinate reference system information.}

\item{filetype}{Character string, defaults to 'pdf' for saving a pdf page for distribution with data,}

\item{buf_prcnt}{The amount to buffer the extent around the focal taxons range by. Defaults to 0.025 oor 2.5\%
but 'png' (or any other format supported by ?ggsave) can be used to create
a map for embedding in a publication or poster.}

\item{SZName}{Character. The field containing the seed zone, defaults to 'SZName'.}
}
\value{
Writes a PDF (or other specified \code{filetype}) to disk, and returns the ggplot object to console allowing user to modify it for other purposes.
}
\description{
Create a full page PDF map for distributing with the eSTZ for quick refernce by users.
The function will also return the map as a ggplot object if you want to make further modifications to it.
These maps are intended for being seen in a large format size, and may not be suitable for including in a manuscript or publication, outsize the appendeix or online references.
If you like components of the map, and want to try and make them for a smaller format, you can rip out the source code and go from there; don't worry this map is very simple so there isn't much to figure out there.
You can visualize source code by typing either: \code{mapmakR} (without a function argument) into the R console, or in a more intuitive format on Github at: https://github.com/sagesteppe/eSTZwritR/blob/main/R/mapmakR.R .
}
\examples{
#library(eSTZwritR)
acth7 <- sf::st_read(file.path(
  system.file(package="eSTZwritR"), "extdata", 'ACTH7.gpkg')
)

mapmakR(acth7,
 species = 'Eriocoma thurberiana',
 save = FALSE,
 landscape = FALSE,
 ecoregions = TRUE,
 cities = TRUE,
 SZName = 'zone',
 caption = 'Data from Johnson et al. 2017. https://doi.org/10.1016/j.rama.2017.01.004'
 )
}
