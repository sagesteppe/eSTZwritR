library(testthat)
library(eSTZwritR)
library(sf)

# Load ACTH7 dataset
acth7 <- sf::st_read(
  system.file("extdata", "ACTH7.gpkg", package = "eSTZwritR"),
  quiet = TRUE
)

# Load cities data for mapmakR
cities.sf <- sf::st_read(
  system.file("extdata", "Carto_cities.gpkg", package = "eSTZwritR"),
  quiet = TRUE
)

test_that("mapmakR errors when sci_name is missing", {
  expect_error(mapmakR(acth7, caption = "Test caption", SZName = zone), "sci_name")
})

test_that("mapmakR returns ggplot object without saving", {

  p <- mapmakR(
    x = acth7,
    sci_name = "Eriocoma thurberiana",
    save = FALSE,
    caption = "Test caption",
    cities = TRUE,
    ecoregions = FALSE,
    SZName = zone
  )

  expect_s3_class(p, "ggplot")
})

test_that("mapmakR saves a file when save = TRUE", {

  td <- tempdir()
  fname <- file.path(td, "Eriocoma_thurberiana_STZmap.pdf")

  p <- mapmakR(
    x = acth7,
    sci_name = "Eriocoma thurberiana",
    save = TRUE,
    outpath = td,
    caption = "Test caption",
    cities = TRUE,
    ecoregions = FALSE,
    SZName = zone
  )

  expect_true(file.exists(fname))

  # Clean up
  unlink(fname)
})
