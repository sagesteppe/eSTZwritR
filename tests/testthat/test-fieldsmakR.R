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
