
<!-- README.md is generated from README.Rmd. Please edit that file -->

# perpsnip

<!-- badges: start -->

<!-- badges: end -->

## Package overview

Title: ***‘tidymodels’ Interface for ‘PerpetualBooster’***

This package serves as a bridge to `{tidymodels}`, allowing you to
manifest `{tidymodels}` API and PerpetualBooster at the same time.

## Installation

Install `{perpsnip}` on R-universe

``` r
install.packages("perpsnip", repos = "https://joshuamarie.r-universe.dev")
```

You can install the development version of perpsnip from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("joshuamarie/perpsnip")
```

<!-- README.md is generated from README.Rmd. Please edit that file -->

# perpsnip

<!-- badges: start -->

[![R-CMD-check](https://github.com/joshuamarie/perpsnip/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/joshuamarie/perpsnip/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Provides a ‘parsnip’ model specification for the ‘PerpetualBooster’
algorithm implemented in the ‘perpetual’ package. PerpetualBooster is a
self-generalizing gradient boosting machine that eliminates the need for
hyperparameter search by automatically tuning itself within a
user-supplied computational budget. This package exposes classification,
regression, and (optionally) censored regression modes so that
PerpetualBooster can be used inside any ‘tidymodels’ workflow, including
hyperparameter tuning with ‘tune’ and performance evaluation with
‘yardstick’.

## Installation

Install from R-universe:

``` r
install.packages("perpsnip", repos = "https://joshuamarie.r-universe.dev")
```

Or the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("joshuamarie/perpsnip")
```

## Usage

PerpetualBooster handles both classification and regression task.

### Classification with iris

``` r
perpsnip::perpsnip(mode = "classification", budget = 0.5) |>
    parsnip::fit(Species ~ ., data = iris) |>
    parsnip::augment(new_data = iris) |>
    yardstick::metrics(truth = Species, estimate = .pred_class)
#> # A tibble: 2 × 3
#>   .metric  .estimator .estimate
#>   <chr>    <chr>          <dbl>
#> 1 accuracy multiclass     0.967
#> 2 kap      multiclass     0.95
```

### Regression with mtcars

``` r
perpetual::perpsnip(mode = "regression", budget = 1) |>
    parsnip::fit(mpg ~ cyl + . - vs - am, data = mtcars) |>
    parsnip::augment(new_data = mtcars) |>
    yardstick::metrics(truth = mpg, estimate = .pred)
#> # A tibble: 3 × 3
#>   .metric .estimator .estimate
#>   <chr>   <chr>          <dbl>
#> 1 rmse    standard       1.25 
#> 2 rsq     standard       0.964
#> 3 mae     standard       1.02
```

## Related

- [`{perpetual}`](https://github.com/perpetual-ml/perpetual) — the
  underlying PerpetualBooster engine
- [`{parsnip}`](https://parsnip.tidymodels.org) — the modeling API this
  package extends
