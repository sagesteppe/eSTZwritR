test_that("dirmakR creates standard directory structure and writes vector data", {

  td <- withr::local_tempdir()

  x <- sf::st_as_sf(
    data.frame(id = 1),
    coords = c("id", "id"),
    crs = 4326
  )

  sf::st_geometry(x) <- sf::st_sfc(
    sf::st_polygon(list(rbind(
      c(0, 0),
      c(1, 0),
      c(1, 1),
      c(0, 1),
      c(0, 0)
    ))),
    crs = 4326
  )

  dirmakR(
    outpath    = td,
    sci_name   = "Eriocoma thurberiana",
    x          = x,
    nrcs_code  = "ACHT7",
    regioncode = "CGB-CPN",
    estz_type  = "cg"
  )

  root <- file.path(td, "Eriocoma_thurberiana_cgSTZ")

  expect_true(dir.exists(root))
  expect_true(dir.exists(file.path(root, "Information")))
  expect_true(dir.exists(file.path(root, "Data", "Vector")))
  expect_true(dir.exists(file.path(root, "Data", "Raster")))

  shp <- file.path(
    root, "Data", "Vector",
    "ACHT7_cgSTZ_CGB-CPN.shp"
  )

  expect_true(file.exists(shp))
})


test_that("dirmakR warns and does not overwrite existing directory by default", {

  td <- withr::local_tempdir()

  dir.create(file.path(td, "Test_cgSTZ"))

  expect_message(
    dirmakR(
      outpath    = td,
      sci_name   = "Test",
      x          = sf::st_as_sf(sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326)),
      nrcs_code  = "TEST",
      regioncode = "X",
      estz_type  = "cg"
    ),
    "was found"
  )
})

