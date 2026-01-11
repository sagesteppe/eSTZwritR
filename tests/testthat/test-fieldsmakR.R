library(testthat)
library(eSTZwritR)
library(sf)
library(dplyr)

# Load the ACTH7 dataset
acth7 <- sf::st_read(
  system.file("extdata", "ACTH7.gpkg", package = "eSTZwritR"),
  quiet = TRUE
)


test_that("fieldsmakR creates required fields and orders them correctly", {

  ob <- fieldsmakR(acth7, SeedZone = "GRIDCODE", SZName = "zone")

  # Check required columns
  expect_true(all(c("ID", "SeedZone", "SZName", "AreaAcres") %in% colnames(ob)))

  # Check that ID is sequential
  expect_equal(ob$ID, seq_len(nrow(ob)))


  # AreaAcres should be numeric
  expect_true(is.numeric(ob$AreaAcres))
})

test_that("fieldsmakR standardizes BIO column names correctly", {

  # Add contrived BIO columns to test renaming
  ob <- mutate(acth7, 
      bio1_sd = runif(nrow(acth7), 5, 7),
      bio8_mean = runif(nrow(acth7), 10, 15)
    )

  ob2 <- fieldsmakR(ob, SeedZone = "GRIDCODE", SZName = "zone")

  expect_true(all(grepl("^BIO", colnames(ob2)[grepl("bio", colnames(ob2))])))
  expect_true(all(grepl("_SD|_mean", colnames(ob2)[grepl("BIO", colnames(ob2))])))
})

test_that("fieldsmakR emits message for unknown columns", {

  ob <- mutate(acth7, unknown_col = seq_len(nrow(acth7)))

  expect_message(
    fieldsmakR(ob, SeedZone = "GRIDCODE", SZName = "zone"),
    "unknown_col"
  )
})


test_that("fieldsmakR renames SeedZone column correctly", {
  df <- data.frame(
    gridcode = c(1, 2, 3),
    zone = c("A", "B", "C")
  )
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'gridcode')
  
  expect_true("SeedZone" %in% colnames(result))
  expect_false("gridcode" %in% colnames(result))
})

test_that("fieldsmakR creates ID when missing", {
  df <- data.frame(
    seedzone = c(1, 2, 3)
  )
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'seedzone')
  
  expect_true("ID" %in% colnames(result))
  expect_equal(result$ID, 1:3)
})

test_that("fieldsmakR uses existing ID column", {
  df <- data.frame(
    id = c(10, 20, 30),
    seedzone = c(1, 2, 3)
  )
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'seedzone')
  
  expect_true("ID" %in% colnames(result))
  expect_equal(result$ID, c(10, 20, 30))
})

test_that("fieldsmakR creates SZName from SeedZone when missing", {
  df <- data.frame(
    seedzone = c(1, 2, 3)
  )
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'seedzone')
  
  expect_equal(result$SZName, result$SeedZone)
})

test_that("fieldsmakR uses provided SZName column", {
  df <- data.frame(
    seedzone = c(1, 2, 3),
    zone_name = c("Zone A", "Zone B", "Zone C")
  )
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'seedzone', SZName = 'zone_name')
  
  expect_equal(result$SZName, c("Zone A", "Zone B", "Zone C"))
})

test_that("fieldsmakR calculates AreaAcres when missing and CRS != 5070", {
  df <- data.frame(seedzone = c(1, 2, 3))
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'seedzone')
  
  expect_true("AreaAcres" %in% colnames(result))
  expect_true(is.numeric(result$AreaAcres))
  expect_true(all(result$AreaAcres > 0))
})

test_that("fieldsmakR calculates AreaAcres when CRS is already 5070", {
  df <- data.frame(seedzone = c(1, 2, 3))
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    sf::st_transform(5070) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'seedzone')
  
  expect_true("AreaAcres" %in% colnames(result))
  expect_true(is.numeric(result$AreaAcres))
})

test_that("fieldsmakR uses provided AreaAcres column", {
  df <- data.frame(
    seedzone = c(1, 2, 3),
    area = c(100, 200, 300)
  )
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'seedzone', AreaAcres = 'area')
  
  expect_equal(result$AreaAcres, c(100, 200, 300))
})

test_that("fieldsmakR standardizes BIO column names", {
  df <- data.frame(
    seedzone = c(1, 2, 3),
    bio1_mean = c(10, 11, 12),
    bio12_sd = c(5, 6, 7),
    bio5_range = c(20, 21, 22)
  )
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'seedzone')
  
  expect_true("BIO1_mean" %in% colnames(result))
  expect_true("BIO12_SD" %in% colnames(result))
  expect_true("BIO5_R" %in% colnames(result))
})

test_that("fieldsmakR handles mixed BIO and non-BIO columns", {
  df <- data.frame(
    seedzone = c(1, 2, 3),
    bio1_mean = c(10, 11, 12),
    custom_field = c("A", "B", "C")
  )
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  expect_message(
    result <- fieldsmakR(nc, SeedZone = 'seedzone'),
    "custom_field"
  )
  
  expect_true("custom_field" %in% colnames(result))
})

test_that("fieldsmakR orders columns correctly with only required fields", {
  df <- data.frame(seedzone = c(1, 2, 3))
  
  nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE) |>
    dplyr::select(geometry) |>
    dplyr::slice_head(n = 3) |>
    dplyr::bind_cols(df)
  
  result <- fieldsmakR(nc, SeedZone = 'seedzone')
  
  expect_equal(colnames(result)[1:4], c("ID", "SeedZone", "SZName", "AreaAcres"))
  expect_equal(colnames(result)[length(colnames(result))], "geometry")
})