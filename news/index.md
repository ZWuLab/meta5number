# Changelog

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
