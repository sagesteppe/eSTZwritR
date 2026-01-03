#' buffR
#'
#' @description buffer an input STZ to determine map extents
#' @param x an input STZ, as vector or raster data -vector is much preferred for speed.
#' @param buf_prcnt the amount of buffering to add to the map, defaults to 0.005 or 0.5%
#' @keywords internal
#' @return a bounding box around the eSTZ product of the specified buffer amount.
buffR <- function(x, buf_prcnt){

  if(missing(buf_prcnt)){buf_prcnt <- 0.025}

  # convert to planar with meter measurement for calculations.

  range <- sf::st_bbox(x)
  x_buf <- (range[['xmax']] - range[['xmin']]) * buf_prcnt
  y_buf <- (range[['ymax']] - range[['ymin']]) * buf_prcnt

  range[['xmax']] <- range[['xmax']] + x_buf
  range[['xmin']] <- range[['xmin']] - x_buf
  range[['ymax']] <- range[['ymax']] + y_buf
  range[['ymin']] <- range[['ymin']] - y_buf

  range
}
