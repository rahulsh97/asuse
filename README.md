
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![R-CMD-check](https://github.com/rahulsh97/asuse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rahulsh97/asuse/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# asuse

The goal of asuse is to provide a long dataset of the Annual Survey of
Unincorporated Sector Enterprises (ASUSE) from India.

## Example

Install the package from GitHub and load it:

``` r
# install.packages("devtools")
devtools::install_github("rahulsh97/asuse")
```

``` r
library(asuse)
```

Because of the datasets size, the package provides a function to
download the datasets and create a local DuckDB database. This results
in a CRAN-compliant package.

Here is how to get the ASUSE database ready for use:

``` r
asuse_download()
```

Check the proportion of rural and urban companies in the survey (See
<https://microdata.gov.in/NADA/index.php/catalog/238/data-dictionary/F17?file_name=LEVEL%20-%2001(Block%201%20&%20item%201503,%201508%20of%20Block%2015>)):

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(duckdb)
#> Loading required package: DBI

con <- dbConnect(duckdb(), asuse_file_path())

dbListTables(con)
#>  [1] "2023-24-level01" "2023-24-level02" "2023-24-level03" "2023-24-level04"
#>  [5] "2023-24-level05" "2023-24-level06" "2023-24-level07" "2023-24-level08"
#>  [9] "2023-24-level09" "2023-24-level10" "2023-24-level11" "2023-24-level12"
#> [13] "2023-24-level13" "2023-24-level14" "2023-24-level15" "2023-24-level16"

tbl(con, "2023-24-level01") %>%
  count(sector) %>%
  mutate(
    sector = case_when(
      sector == 1L ~ "Rural",
      sector == 2L ~ "Urban",
      TRUE ~ NA_character_
    ),
    pct = n / sum(n)
  ) %>%
  collect()
#> Warning: Missing values are always removed in SQL aggregation functions.
#> Use `na.rm = TRUE` to silence this warning
#> This warning is displayed once every 8 hours.
#> # A tibble: 2 × 3
#>   sector      n   pct
#>   <chr>   <dbl> <dbl>
#> 1 Rural  283448 0.528
#> 2 Urban  253751 0.472

dbDisconnect(con, shutdown = TRUE)
```

# Adding older/newer years

Microdata:
<https://microdata.gov.in/NADA/index.php/catalog/238/get-microdata>

1.  Install the Nesstar Explorer (e.g. ASUSE 2023-24 includes it)
2.  Extract the RAR files downloaded from the microdata website to
    data-raw/202324 or what year you are adding
3.  Export the .Nesstar file to Stata (SAV) format with “Export
    Datasets” and the metadata with “Export DDI” using the Nesstar
    Explorer
4.  Update `00-tidy-data.r` and run it
5.  Update the available datasets in `R/available_datasets.R`
6.  Update the new RDS files in the ‘Releases’ section of the GitHub
    repository
7.  Regenerate the database with `asuse_delete()` and `asuse_download()`
