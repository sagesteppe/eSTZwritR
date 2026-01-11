library(testthat)
library(eSTZwritR)
library(sf)
library(dplyr)

# Load the ACTH7 dataset
acth7 <- sf::st_read(
  system.file("extdata", "ACTH7.gpkg", package = "eSTZwritR"),
  quiet = TRUE
)

test_that("regionCoding returns correct structure and types", {
  
  # Run the function with default sample size and default regions
  rc <- regionCoding(acth7)
  
  # SuggestedName should be a character
  expect_type(rc$SuggestedName, "character")
  expect_gt(nchar(rc$SuggestedName), 0)
  
  # RegionsCovered should be a tibble/data.frame
  expect_s3_class(rc$RegionsCovered, "data.frame")
  expect_true(all(c("REG_ABB", "n") %in% colnames(rc$RegionsCovered)))
  
})

test_that("regionCoding respects sample size argument (approximate)", {
  tol <- 0.1  # 10% tolerance
  
  # smaller n
  n_small <- 100
  rc_small <- regionCoding(acth7, n = n_small)
  expect_gte(sum(rc_small$RegionsCovered$n), n_small * (1 - tol))
  expect_lte(sum(rc_small$RegionsCovered$n), n_small * (1 + tol))
  
  # larger n
  n_large <- 2000
  rc_large <- regionCoding(acth7, n = n_large)
  expect_gte(sum(rc_large$RegionsCovered$n), n_large * (1 - tol))
  expect_lte(sum(rc_large$RegionsCovered$n), n_large * (1 + tol))
})


test_that("regionCoding works with user-supplied regions", {
  # load regions and take a subset
  regions <- sf::st_read(
    system.file("extdata", "regions.gpkg", package = "eSTZwritR"), quiet = TRUE
  )
  
  regions_sub <- regions[1:5, ]
  
  rc_sub <- regionCoding(acth7, n = 200, regions = regions_sub)
  
  # SuggestedName should be from the subset
  expect_true(all(unlist(strsplit(rc_sub$SuggestedName, "-")) %in% regions_sub$REG_ABB))
})

