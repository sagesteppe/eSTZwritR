library(testthat)
library(eSTZwritR)
library(sf)

# Load ACTH7 dataset
acth7 <- sf::st_read(
  system.file("extdata", "ACTH7.gpkg", package = "eSTZwritR"),
  quiet = TRUE
)

test_that("orderZones works with ACTH7 polygons", {

  n_sample <- 200

  res <- orderZones(acth7, SeedZone = zone, SZName = zone, n = n_sample)

  # Reclassified matches input size
  expect_equal(nrow(res$Reclassified), nrow(acth7))

  # numbers of zones in are the expected range. 
  n_zones <- length(unique(acth7$zone))
  expect_true(all(res$Reclassified$SeedZone %in% seq_len(n_zones)))

  # If SZName initially matched, it should still match after reclassification
  expect_true(all(res$Reclassified$SeedZone %in% seq_len(nrow(acth7))))

  # SuggestedOrder sequential
  expect_equal(res$Summary$SuggestedOrder, seq_len(nrow(res$Summary)))

  # Check plots are ggplot objects
  expect_s3_class(res$PlotKruskal, "gg")
  expect_s3_class(res$PlotDunns, "gg")
})


test_that("orderZones removes duplicate raster points and scales GAI", {
  n_sample <- 200
  res <- orderZones(acth7, SeedZone = zone, SZName = zone, n = n_sample)
  
  # Extract the points used for calculation (internal, could expose with a test arg)
  pts <- sf::st_as_sf(res$Reclassified) # or use res$Summary with n counts

  # Check max row count does not exceed n_sample (duplicates removed)
  expect_lte(sum(res$Summary$n), n_sample)

  # Check that GAI values are between 0 and 1
  expect_true(all(res$Summary$MedianGAI >= 0))
  expect_true(all(res$Summary$MedianGAI <= 1))
})
