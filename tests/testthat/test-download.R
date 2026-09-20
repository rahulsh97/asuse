test_that("asuse_download does not attempt a network call when a matching local database already exists", {
  tmp_root <- file.path(tempdir(), paste0("asuse-test-download-", as.integer(Sys.time())))
  dir.create(tmp_root)

  old_env <- Sys.getenv("ASUSE_PATH", unset = NA)
  Sys.setenv(ASUSE_PATH = tmp_root)
  on.exit({
    if (is.na(old_env)) Sys.unsetenv("ASUSE_PATH") else Sys.setenv(ASUSE_PATH = old_env)
    unlink(tmp_root, recursive = TRUE)
  }, add = TRUE)

  duckdb_version <- utils::packageVersion("duckdb")
  existing_file <- file.path(
    tmp_root,
    paste0("asuse_duckdb_v", gsub("\\.", "", duckdb_version), ".sql")
  )
  writeLines("dummy", existing_file)

  # A real download attempt would either error (no network in the test
  # environment) or take much longer than a guard-clause return. Asserting
  # the specific message and that the placeholder file survives untouched
  # confirms the existing-file short-circuit runs before any network call.
  expect_message(asuse_download(), "already a census database")
  expect_true(file.exists(existing_file))
  expect_identical(readLines(existing_file), "dummy")
})
