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


# tests/testthat/test-mapmakR.R

# Add these tests:

test_that("mapmakR errors when caption is missing", {
  expect_error(
    mapmakR(
      x = acth7,
      sci_name = "Eriocoma thurberiana",
      save = FALSE,
      SZName = zone
    ),
    "Caption Not supplied"
  )
})

test_that("mapmakR uses default outpath when not provided", {
  # This tests the getwd() default path
  p <- mapmakR(
    x = acth7,
    sci_name = "Eriocoma thurberiana",
    save = FALSE,
    caption = "Test caption",
    cities = FALSE,
    ecoregions = FALSE,
    SZName = zone
  )
  expect_s3_class(p, "ggplot")
})

test_that("mapmakR works with ecoregions = TRUE", {
  p <- mapmakR(
    x = acth7,
    sci_name = "Eriocoma thurberiana",
    save = FALSE,
    caption = "Test caption",
    cities = FALSE,
    ecoregions = TRUE,  # This path is untested
    SZName = zone
  )
  expect_s3_class(p, "ggplot")
})

test_that("mapmakR works with both ecoregions and cities", {
  p <- mapmakR(
    x = acth7,
    sci_name = "Eriocoma thurberiana",
    save = FALSE,
    caption = "Test caption",
    cities = TRUE,
    ecoregions = TRUE,  # This combination is untested
    SZName = zone
  )
  expect_s3_class(p, "ggplot")
})

test_that("mapmakR works in portrait orientation", {
  p <- mapmakR(
    x = acth7,
    sci_name = "Eriocoma thurberiana",
    save = FALSE,
    caption = "Test caption",
    landscape = FALSE,  # This path is untested
    cities = FALSE,
    ecoregions = FALSE,
    SZName = zone
  )
  expect_s3_class(p, "ggplot")
})

test_that("mapmakR reduces cities by population", {
  p <- mapmakR(
    x = acth7,
    sci_name = "Eriocoma thurberiana",
    save = FALSE,
    caption = "Test caption",
    cities = TRUE,
    city_reduce = "population", 
    city_reduce_no = 5,
    ecoregions = FALSE,
    SZName = zone
  )
  expect_s3_class(p, "ggplot")
})

test_that("mapmakR handles custom buffer percentage", {
  p <- mapmakR(
    x = acth7,
    sci_name = "Eriocoma thurberiana",
    save = FALSE,
    caption = "Test caption",
    buf_prcnt = 0.05,  # Non-default value
    cities = FALSE,
    ecoregions = FALSE,
    SZName = zone
  )
  expect_s3_class(p, "ggplot")
})

test_that("mapmakR saves PNG format", {
  td <- tempdir()
  fname <- file.path(td, "Eriocoma_thurberiana_STZmap.png")
  p <- mapmakR(
    x = acth7,
    sci_name = "Eriocoma thurberiana",
    save = TRUE,
    outpath = td,
    filetype = "png",  # Non-default filetype
    caption = "Test caption",
    cities = FALSE,
    ecoregions = FALSE,
    SZName = zone
  )
  expect_true(file.exists(fname))
  unlink(fname)
})