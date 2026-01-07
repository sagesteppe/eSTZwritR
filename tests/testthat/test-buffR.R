library(testthat)
library(eSTZwritR)
library(sf)

test_that("buffR uses default buffer when buf_prcnt is missing", {

  x <- sf::st_as_sf(
    data.frame(id = 1),
    coords = c("id", "id"),
    crs = 4326
  )

  sf::st_geometry(x) <- sf::st_sfc(
    sf::st_polygon(list(rbind(
      c(0, 0),
      c(10, 0),
      c(10, 10),
      c(0, 10),
      c(0, 0)
    ))),
    crs = 4326
  )

  res_default <- buffR(x)
  res_explicit <- buffR(x, 0.025)

  expect_equal(res_default, res_explicit)
})

test_that("buffR expands bounding box by specified percentage", {
  # minimal example sf object
  poly <- sf::st_sfc(sf::st_polygon(list(rbind(
    c(0,0), c(10,0), c(10,20), c(0,20), c(0,0)
  ))), crs = 4326)
  
  res <- buffR(poly, buf_prcnt = 0.1)
  
  x_range <- 10
  y_range <- 20
  expect_equal(res[["xmin"]], 0 - x_range * 0.1)
  expect_equal(res[["xmax"]], 10 + x_range * 0.1)
  expect_equal(res[["ymin"]], 0 - y_range * 0.1)
  expect_equal(res[["ymax"]], 20 + y_range * 0.1)
})
