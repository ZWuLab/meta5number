# Changelog

## meta5number 0.2.1

- This version corrects a defect that meta5number 0.2.0 has when it runs
  with version 0.3.0 of `orderStatMoments`, and it replaces 0.2.0. The
  functions that take a precomputed `moments` object
  ([`c_mu()`](https://zwulab.github.io/meta5number/reference/c_mu.md),
  [`c_sigma()`](https://zwulab.github.io/meta5number/reference/c_sigma.md),
  [`imputed_moments()`](https://zwulab.github.io/meta5number/reference/imputed_moments.md)
  and
  [`estimator_weights()`](https://zwulab.github.io/meta5number/reference/estimator_weights.md))
  check that the object holds the moments of the standard normal order
  statistics. Since its version 0.3.0, `orderStatMoments` stores the
  constants `a` and `b` of a distribution `a + bZ` in the component
  `affine`, where it stored them in `location` and `scale` before, and
  the check of 0.2.0 read the former names. With `orderStatMoments`
  0.3.0 the check was therefore skipped: an object computed with `mean`,
  `sd`, `os_shift` or `os_multiplier` away from their defaults was
  accepted without a message, and results computed from it were wrong
  (the factor that
  [`c_mu()`](https://zwulab.github.io/meta5number/reference/c_mu.md)
  returns, for example). The check now reads `affine`, and it stops when
  an object of `orderStatMoments` does not carry that component. A call
  without `moments`, or with the object of the standard normal, was not
  affected, and its results are unchanged.

- The package requires `orderStatMoments` 0.3.0 or later
  (`Imports: orderStatMoments (>= 0.3.0)`). Update it with
  `remotes::install_github("ZWuLab/orderStatMoments")`.

- The references cite `orderStatMoments` at its version 0.3.0, and its
  paper by the title it has now, “orderStatMoments: Exact Means,
  Variances, and Covariances of Order Statistics in R”.

## meta5number 0.2.0

- The engine of the exact moments is now the package `orderStatMoments`,
  renamed from `osmoments`, and every call and the `Imports` field
  follow it. Install it with
  `remotes::install_github("ZWuLab/orderStatMoments")`.

- The package is renamed `meta5number` (it was `fivenumMeta` in 0.1.0),
  so that the name says what it is for: meta-analysis from five-number
  summaries. The functions, their arguments and their results are
  unchanged.
  [`library(meta5number)`](https://zwulab.github.io/meta5number/)
  replaces
  [`library(fivenumMeta)`](https://rdrr.io/r/base/library.html), and the
  old installation should be removed first
  (`remove.packages("fivenumMeta")`).

- The constants of the shortcut formulas
  [`c_mu_shortcut()`](https://zwulab.github.io/meta5number/reference/c_mu_shortcut.md)
  and
  [`c_sigma_shortcut()`](https://zwulab.github.io/meta5number/reference/c_sigma_shortcut.md)
  carry two decimals, as Table 3 of the paper and its supplement table
  print them since the refit on the paper’s grid of 40 sample sizes (n =
  901 added). The anchors keep four decimals, since they are the limits
  of the paper’s Theorem 1. The documented errors were recomputed and
  are of the same size as before (at most 0.42% on the grid for the
  BLUE’s formulas). The constants of 0.1.0, for the record: BLUE, mean,
  S1 (2.006, -0.810), S2 (0.142), S3 (0.838, -0.576); SD, S1 (0.8278,
  0.330, 1.2041), S2 (-0.863), S3 (5.267, -10.364, 8.327); Wan-Luo-Shi
  version, mean, S1 (2.006, -0.811), S2 (0.142), S3 (0.835, -0.572); SD,
  S1 (0.8705, 0.418, 1.2199), S2 (-0.845), S3 (5.191, -10.204, 8.525).

- The test grid of `test-exact-any-n.R` has 40 sample sizes (n = 901
  added).
