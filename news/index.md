# Changelog

## meta5number 0.3.1

- Jiandong Shi and Tiejun Tong are authors of the package.

- Two data sets, `bun_icu` and `hgb_icu`: the study summaries of blood
  urea nitrogen and of hemoglobin in COVID-19 patients in and outside
  intensive care, seven studies each, as McGrath et al. (2023) published
  them from the review of Katzenschlager et al. (2021), under the MIT
  license (the notice is in the file `COPYRIGHTS`).

- The vignette `two-meta-analyses` now runs the two meta-analyses of Wu,
  Shi and Tong

  2026. on these data: the mean difference of blood urea nitrogen and
        the SD ratio of hemoglobin, after the skewness test of Shi et
        al. (2023) screens the studies, under the common-effect and the
        random-effects models. The analyses of the vitamin D and the age
        data, the examples of an earlier version of the paper, left the
        vignette. The data set `vitd` stays as example data.

- The paper is cited by its present title, “Precision of the imputed
  mean and standard deviation from the five-number summary”, and the
  help pages write “inflation factor” in full.

- No function changed, and every result of version 0.3.0 is unchanged.

## meta5number 0.3.0

- Any set of reported quantiles. The new function
  [`reporting_scenario()`](https://zwulab.github.io/meta5number/reference/reporting_scenario.md)
  describes what a study reports by the probabilities of its sample
  quantiles, with or without the minimum and the maximum, for example
  `reporting_scenario(c(0.05, 0.5, 0.95))` for the median with the 5th
  and 95th percentiles. Its result is passed as the argument `scenario`
  of
  [`se_imputed()`](https://zwulab.github.io/meta5number/reference/se_imputed.md),
  [`c_mu()`](https://zwulab.github.io/meta5number/reference/c_mu.md),
  [`c_sigma()`](https://zwulab.github.io/meta5number/reference/c_sigma.md),
  [`inflation_factors()`](https://zwulab.github.io/meta5number/reference/inflation_factors.md),
  [`estimator_weights()`](https://zwulab.github.io/meta5number/reference/estimator_weights.md)
  and
  [`imputed_moments()`](https://zwulab.github.io/meta5number/reference/imputed_moments.md),
  which compute the BLUE from these reported values and its exact
  factors at every sample size that is at least the number of reported
  values. The named scenarios `"S1"` to `"S5"` are special cases and
  give the results they gave before.

- A quantile definition of your own. The argument `type` takes, besides
  the nine definitions of
  [`quantile()`](https://rdrr.io/r/stats/quantile.html), a function of
  the probabilities `p` and the sample size `n` that returns the ranks
  `r` and the weights `gamma` of the rule
  `(1 - gamma) x[r] + gamma x[r + 1]`. The help of
  [`se_imputed()`](https://zwulab.github.io/meta5number/reference/se_imputed.md)
  and Appendix C of the vignette write Tukey’s hinges, the quartiles of
  [`fivenum()`](https://rdrr.io/r/stats/fivenum.html), as such a rule.

- The print of
  [`se_imputed()`](https://zwulab.github.io/meta5number/reference/se_imputed.md)
  names a
  [`reporting_scenario()`](https://zwulab.github.io/meta5number/reference/reporting_scenario.md)
  by its reported values and a rule by “a user-supplied quantile rule”.

- [`imputed_moments()`](https://zwulab.github.io/meta5number/reference/imputed_moments.md)
  checks the length of the weights given as `w_mean` and `w_sd`, and
  [`c_mu_shortcut()`](https://zwulab.github.io/meta5number/reference/c_mu_shortcut.md)
  and
  [`c_sigma_shortcut()`](https://zwulab.github.io/meta5number/reference/c_sigma_shortcut.md)
  say that the shortcut formulas exist for the scenarios S1 to S3 when
  they are given another scenario.

- The paper of the engine, Wu and Tong (2026), is cited as
  arXiv:2611.19980 (<https://doi.org/10.48550/arXiv.2611.19980>), where
  it was cited as a manuscript, and `orderStatMoments` at its version
  0.3.1.

- The results for the scenarios `"S1"` to `"S5"` and the quantile
  definitions 1 to 9 are those of 0.2.1.

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
