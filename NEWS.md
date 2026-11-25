# meta5number 0.3.1

* Jiandong Shi and Tiejun Tong are authors of the package.

* Two data sets, `bun_icu` and `hgb_icu`: the study summaries of blood urea nitrogen and
  of hemoglobin in COVID-19 patients in and outside intensive care, seven studies each,
  as McGrath et al. (2023) published them from the review of Katzenschlager et al.
  (2021), under the MIT license (the notice is in the file `COPYRIGHTS`).

* The vignette `two-meta-analyses` now runs the two meta-analyses of Wu, Shi and Tong
  (2026) on these data: the mean difference of blood urea nitrogen and the SD ratio of
  hemoglobin, after the skewness test of Shi et al. (2023) screens the studies, under
  the common-effect and the random-effects models. The analyses of the vitamin D and
  the age data, the examples of an earlier version of the paper, left the vignette. The
  data set `vitd` stays as example data.

* The paper is cited by its present title, "Precision of the imputed mean and standard
  deviation from the five-number summary", and the help pages write "inflation factor"
  in full.

* No function changed, and every result of version 0.3.0 is unchanged.

# meta5number 0.3.0

* Any set of reported quantiles. The new function `reporting_scenario()` describes what
  a study reports by the probabilities of its sample quantiles, with or without the
  minimum and the maximum, for example `reporting_scenario(c(0.05, 0.5, 0.95))` for the
  median with the 5th and 95th percentiles. Its result is passed as the argument
  `scenario` of `se_imputed()`, `c_mu()`, `c_sigma()`, `inflation_factors()`,
  `estimator_weights()` and `imputed_moments()`, which compute the BLUE from these
  reported values and its exact factors at every sample size that is at least the number
  of reported values. The named scenarios
  `"S1"` to `"S5"` are special cases and give the results they gave before.

* A quantile definition of your own. The argument `type` takes, besides the nine
  definitions of `quantile()`, a function of the probabilities `p` and the sample size
  `n` that returns the ranks `r` and the weights `gamma` of the rule
  `(1 - gamma) x[r] + gamma x[r + 1]`. The help of `se_imputed()` and Appendix C of the
  vignette write Tukey's hinges, the quartiles of `fivenum()`, as such a rule.

* The print of `se_imputed()` names a `reporting_scenario()` by its reported values and
  a rule by "a user-supplied quantile rule".

* `imputed_moments()` checks the length of the weights given as `w_mean` and `w_sd`, and
  `c_mu_shortcut()` and `c_sigma_shortcut()` say that the shortcut formulas exist for the
  scenarios S1 to S3 when they are given another scenario.

* The paper of the engine, Wu and Tong (2026), is cited as arXiv:2611.19980
  (<https://doi.org/10.48550/arXiv.2611.19980>), where it was cited as a manuscript, and
  `orderStatMoments` at its version 0.3.1.

* The results for the scenarios `"S1"` to `"S5"` and the quantile definitions 1 to 9 are
  those of 0.2.1.

# meta5number 0.2.1

* This version corrects a defect that meta5number 0.2.0 has when it runs with
  version 0.3.0 of `orderStatMoments`, and it replaces 0.2.0. The functions that take
  a precomputed `moments` object (`c_mu()`, `c_sigma()`, `imputed_moments()` and
  `estimator_weights()`) check that the object holds the moments of the standard
  normal order statistics. Since its version 0.3.0, `orderStatMoments` stores the
  constants `a` and `b` of a distribution `a + bZ` in the component `affine`, where it
  stored them in `location` and `scale` before, and the check of 0.2.0 read the former
  names. With `orderStatMoments` 0.3.0 the check was therefore skipped: an object
  computed with `mean`, `sd`, `os_shift` or `os_multiplier` away from their defaults
  was accepted without a message, and results computed from it were wrong (the factor
  that `c_mu()` returns, for example). The check now reads `affine`, and it stops when
  an object of `orderStatMoments` does not carry that component. A call
  without `moments`, or with the object of the standard normal, was not affected, and
  its results are unchanged.

* The package requires `orderStatMoments` 0.3.0 or later
  (`Imports: orderStatMoments (>= 0.3.0)`). Update it with
  `remotes::install_github("ZWuLab/orderStatMoments")`.

* The references cite `orderStatMoments` at its version 0.3.0, and its paper by the
  title it has now, "orderStatMoments: Exact Means, Variances, and Covariances of
  Order Statistics in R".

# meta5number 0.2.0

* The engine of the exact moments is now the package `orderStatMoments`, renamed
  from `osmoments`, and every call and the `Imports` field follow it. Install it
  with `remotes::install_github("ZWuLab/orderStatMoments")`.

* The package is renamed `meta5number` (it was `fivenumMeta` in 0.1.0), so that the name
  says what it is for: meta-analysis from five-number summaries. The functions, their
  arguments and their results are unchanged. `library(meta5number)` replaces
  `library(fivenumMeta)`, and the old installation should be removed first
  (`remove.packages("fivenumMeta")`).

* The constants of the shortcut formulas `c_mu_shortcut()` and `c_sigma_shortcut()` carry
  two decimals, as Table 3 of the paper and its supplement table print them since the refit
  on the paper's grid of 40 sample sizes (n = 901 added). The anchors keep four decimals,
  since they are the limits of the paper's Theorem 1. The documented errors were recomputed
  and are of the same size as before (at most 0.42% on the grid for the BLUE's formulas).
  The constants of 0.1.0, for the record: BLUE, mean, S1 (2.006, -0.810), S2 (0.142), S3
  (0.838, -0.576); SD, S1 (0.8278, 0.330, 1.2041), S2 (-0.863), S3 (5.267, -10.364, 8.327);
  Wan-Luo-Shi version, mean, S1 (2.006, -0.811), S2 (0.142), S3 (0.835, -0.572); SD, S1
  (0.8705, 0.418, 1.2199), S2 (-0.845), S3 (5.191, -10.204, 8.525).

* The test grid of `test-exact-any-n.R` has 40 sample sizes (n = 901 added).

# fivenumMeta 0.1.0

* First release: the functions that accompany the paper of Wu, Shi and Tong
  (2026), "Precision of the imputed mean and standard deviation from a
  five-number summary".

* `se_imputed_df()` takes a meta-analysis data set, one row per study, reads the
  reporting scenario off the columns each row has, and appends the imputed mean
  and SD with their naive and exact plug-in standard errors. A row with a sample
  mean and SD is the scenario `"sample"`, and a row with a mean, the minimum and
  the maximum and no SD is `"mean_range"`: the mean is kept, and the SD is imputed
  from the range. For two groups per row, `se_imputed_diff()` does the same and
  adds the effect of the study with its naive and its exact standard error, in the
  names `metafor::rma()` takes as they are: the difference of means
  (`measure = "MD"`, the default) or the log variability ratio (`measure = "lnVR"`).

* `pool_imputed()` pools the studies of `se_imputed_diff()` in one call, under the
  naive and under the exact standard errors side by side, by the common-effect
  model (`method = "EE"`, the default) or the DerSimonian-Laird random-effects
  model (`"DL"`): the pooled estimate, its standard error, confidence interval and
  p-value, Q, I^2, tau^2 and the weights. REML and the other estimators stay with
  metafor, which takes the same columns.

* `se_imputed()` returns one study's imputed mean and SD with their plug-in
  standard errors, as an object of class `"se_imputed"`: a list with a compact
  print. A row of `se_imputed_df()` whose standard errors would be zero (a
  sample SD of zero, a summary whose values are all equal) gets `NA` and is
  named in the warning with the other rows that cannot be used.

* `c_mu()`, `c_sigma()` and `inflation_factors()` give the exact factors at every
  sample size: a reported quantile is a fixed combination of two neighboring order
  statistics under the definition `type` (1 to 9 as in `quantile()`, default 7).
  So its moments, the estimators and their factors are exact at any n.
  `c_mu_shortcut()` and `c_sigma_shortcut()` give the closed-form shortcut formulas,
  for comparison and for use without the package.

* Every function defaults to the BLUE: `version = "blue"` in the study-level
  functions and `inflation_factors()`, `method = "blue"` in the others.
  `version = "wan_luo_shi"` and the `method` presets give the estimators of Wan,
  Luo and Shi, exact at every sample size as well.

* `estimator_weights()`, `scenario_ranks()` and `imputed_moments()` give the
  weights, the reported ranks and the second moments of the imputed statistics.

* The exact moments of the normal order statistics come from the package
  `osmoments`.

* The data set `vitd` carries the six studies of the vitamin D meta-analysis of
  Nnoaham and Clarke (2008), and the vignette `two-meta-analyses` reproduces the
  two meta-analyses of Wu, Shi and Tong (2026), one of means on `vitd` and one of
  SDs on `metamedian::dat.age`.
