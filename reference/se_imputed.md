# Imputed mean and SD of one study, with their plug-in standard errors

The study-level wrapper for practitioners: give it a study's reported
values and sample size, and it returns the imputed mean \\\hat\mu\\ and
SD \\\hat\sigma\\, the naive standard error \\\hat\sigma/\sqrt n\\ that
treats \\\hat\mu\\ as a sample mean, and the plug-in standard errors
\\\mathrm{SE}(\hat\mu) = C\_\mu(n)\\\hat\sigma\\ and
\\\mathrm{SE}(\hat\sigma) = C\_\sigma(n)\\\hat\sigma\\ built from the
normal-model factors of
[`c_mu`](https://zwulab.github.io/meta5number/reference/c_mu.md) and
[`c_sigma`](https://zwulab.github.io/meta5number/reference/c_sigma.md).
The default estimator version is the BLUE (Lloyd's least-squares
estimators from the reported values, the exact-optimal version of the
Wan-Luo-Shi estimators); `version = "wan_luo_shi"` gives the estimators
of Wan, Luo and Shi (Luo's mean, Wan's SD under S1 and S2, Shi's under
S3, with their closed-form weights and the Blom formulas) and their own
factors. Both are computed exactly at every sample size.

## Usage

``` r
se_imputed(
  q,
  n,
  scenario = c("S3", "S1", "S2", "S4", "S5"),
  version = c("blue", "wan_luo_shi"),
  type = 7
)

# S3 method for class 'se_imputed'
print(x, digits = 4L, ...)
```

## Arguments

- q:

  Named numeric vector of the reported values: `min`, `med`, `max` for
  S1; `q1`, `med`, `q3` for S2; all five (`min`, `q1`, `med`, `q3`,
  `max`) for S3; `p10`, `q1`, `med`, `q3`, `p90` for S4; and `min`,
  `p10`, `q1`, `med`, `q3`, `p90`, `max` for S5, where `p10` and `p90`
  are the 10th and 90th percentiles. Extra names are ignored, a required
  name given twice is an error, and the entries used must be
  non-decreasing. For a
  [`reporting_scenario`](https://zwulab.github.io/meta5number/reference/reporting_scenario.md),
  the reported values in its order (the minimum if reported, the
  quantiles by increasing probability, the maximum if reported), unnamed
  or named by its labels.

- n:

  Integer sample size: at least 3 under S1 and S2, 5 under S3 and S4,
  and 7 under S5, and at least the number of reported values for a
  [`reporting_scenario`](https://zwulab.github.io/meta5number/reference/reporting_scenario.md).

- scenario:

  One of "S1" to "S5", or an object of
  [`reporting_scenario`](https://zwulab.github.io/meta5number/reference/reporting_scenario.md)
  for any other set of reported quantiles.

- version:

  `"blue"` (default) or `"wan_luo_shi"`.

- type:

  The definition of the reported sample quantiles: an integer from 1 to
  9 as in [`quantile`](https://rdrr.io/r/stats/quantile.html); 7, R's
  default, unless the study states another. Or a function
  `function(p, n)` that returns `list(r, gamma)` for a definition
  outside these nine, the quantile at probability \\p\\ being
  \\(1-\gamma)X\_{(r)} + \gamma X\_{(r+1)}\\; see Details and
  [`imputed_moments`](https://zwulab.github.io/meta5number/reference/imputed_moments.md).

- x:

  An object returned by `se_imputed()`.

- digits:

  The number of significant digits the print shows.

- ...:

  Passed to [`print.default`](https://rdrr.io/r/base/print.default.html)
  for the estimates.

## Value

An object of class `"se_imputed"`: a list, used as any list, whose print
shows the estimates, the standard errors and the factors. Its
components: `mu_hat`, `sigma_hat`, `se_naive` \\= \hat\sigma/\sqrt n\\,
`se_mu` \\= C\_\mu(n)\hat\sigma\\, `se_sigma` \\=
C\_\sigma(n)\hat\sigma\\, the factors `c_n` and `c_sigma` used, `exact`
(TRUE: the factors are computed exactly, at every \\n\\), `version` and
`version_used` (the same, kept for the columns of
[`se_imputed_df`](https://zwulab.github.io/meta5number/reference/se_imputed_df.md)),
plus `n`, `scenario`, `type` and the weights `w_mean`, `w_sd`, named by
the reported values as
[`estimator_weights`](https://zwulab.github.io/meta5number/reference/estimator_weights.md)
names them (`a` the minimum, `m` the median, `b` the maximum, `q1`,
`q3`, `p10`, `p90`). The example shows how to pick the fields a
meta-analysis needs.

## Details

The sample size. At \\n = 4Q + 1\\ with integer \\Q \ge 1\\, under the
default definition (type 7), the reported quartiles are the order
statistics at ranks \\Q+1, 2Q+1, 3Q+1\\. At any other \\n\\, each
reported sample quantile is a fixed linear combination of two adjacent
order statistics, and the estimators and their factors are computed
exactly from the means and covariance matrix of the reported values (see
[`imputed_moments`](https://zwulab.github.io/meta5number/reference/imputed_moments.md)).
At such \\n\\ the factors depend on the definition of the sample
quantiles; the median of an even sample is the average of the two middle
values under type 7 (and types 2, 5, 6, 8 and 9).

The shortcut formulas for the factors
([`c_mu_shortcut`](https://zwulab.github.io/meta5number/reference/c_mu_shortcut.md),
[`c_sigma_shortcut`](https://zwulab.github.io/meta5number/reference/c_sigma_shortcut.md))
are not used here. They serve a reader without this package and a
comparison with the exact values.

Under S4 and S5, and for a
[`reporting_scenario`](https://zwulab.github.io/meta5number/reference/reporting_scenario.md),
only the BLUE is defined; `version = "wan_luo_shi"` is an error there.

Other reported quantiles, and other definitions. A study that reports,
say, the median with the 5th and 95th percentiles is described by
`reporting_scenario(c(0.05, 0.5, 0.95))`, and the BLUE and its exact
factors are computed from these three values. A study whose quantiles
follow a definition that is not one of R's nine is given a rule as
`type`. The last example writes Tukey's hinges, the quartiles that
[`fivenum`](https://rdrr.io/r/stats/fivenum.html) returns, as such a
rule: the lower hinge is the median of the lower half of the ordered
sample, the middle value included when \\n\\ is odd, so its position is
\\d = (\lfloor (n+1)/2 \rfloor + 1)/2\\, and the upper hinge is at \\n +
1 - d\\.

A constant summary, all reported values equal, has an imputed SD of
exactly zero (the SD weights sum to zero) and so standard errors of
zero, which cannot enter inverse-variance weights. The function returns
them with a warning;
[`se_imputed_df`](https://zwulab.github.io/meta5number/reference/se_imputed_df.md)
sets such a row to `NA` instead.

Assumptions: iid normal data. The standard errors are plug-in
quantities, \\\sigma\\ being replaced by \\\hat\sigma\\; their reference
distribution is not Student's t and is not supplied here.

## Examples

``` r
r <- se_imputed(c(q1 = 10, med = 12, q3 = 15), n = 25, scenario = "S2")
r                                        # the compact print
#> Imputed mean and SD under S2, n = 25, the BLUE, quantile type 7
#>    mu_hat sigma_hat  se_naive     se_mu  se_sigma 
#>   12.3575    3.9252    0.7850    0.8442    0.9311 
#> Factors: C_mu(n) = 0.2151, C_sigma(n) = 0.2372. The weights are $w_mean and $w_sd; every field with str() or unclass().
r[c("mu_hat", "se_mu")]                  # the fields a meta-analysis needs, as a list
#> $mu_hat
#> [1] 12.35747
#> 
#> $se_mu
#> [1] 0.8441742
#> 
se_imputed(c(q1 = 10, med = 12, q3 = 15), n = 25, scenario = "S2", version = "wan_luo_shi")
#> Imputed mean and SD under S2, n = 25, the Wan-Luo-Shi estimators, quantile type 7
#>    mu_hat sigma_hat  se_naive     se_mu  se_sigma 
#>   12.3578    3.9306    0.7861    0.8453    0.9337 
#> Factors: C_mu(n) = 0.2151, C_sigma(n) = 0.2375. The weights are $w_mean and $w_sd; every field with str() or unclass().
se_imputed(c(q1 = 10, med = 12, q3 = 15), n = 24, scenario = "S2")   # interpolated quartiles
#> Imputed mean and SD under S2, n = 24, the BLUE, quantile type 7
#>    mu_hat sigma_hat  se_naive     se_mu  se_sigma 
#>   12.3634    3.9285    0.8019    0.8544    0.9224 
#> Factors: C_mu(n) = 0.2175, C_sigma(n) = 0.2348. The weights are $w_mean and $w_sd; every field with str() or unclass().
se_imputed(c(min = 3, q1 = 10, med = 12, q3 = 15, max = 30), n = 30, "S3")
#> Imputed mean and SD under S3, n = 30, the BLUE, quantile type 7
#>    mu_hat sigma_hat  se_naive     se_mu  se_sigma 
#>   12.9405    5.6194    1.0260    1.0591    0.8176 
#> Factors: C_mu(n) = 0.1885, C_sigma(n) = 0.1455. The weights are $w_mean and $w_sd; every field with str() or unclass().

# other reported quantiles: the median with the 5th and 95th percentiles
sc <- reporting_scenario(c(0.05, 0.5, 0.95))
se_imputed(c(2.1, 5.0, 8.4), n = 60, scenario = sc)
#> Imputed mean and SD under the reported values (p5, p50, p95), n = 60, the BLUE, quantile type 7
#>    mu_hat sigma_hat  se_naive     se_mu  se_sigma 
#>    5.0961    2.0124    0.2598    0.2831    0.2242 
#> Factors: C_mu(n) = 0.1407, C_sigma(n) = 0.1114. The weights are $w_mean and $w_sd; every field with str() or unclass().

# another definition of the quartiles: Tukey's hinges, as stats::fivenum() computes them
hinges <- function(p, n) {
  d <- (floor((n + 1) / 2) + 1) / 2              # the position of the lower hinge
  pos <- ifelse(p < 0.5, d, ifelse(p > 0.5, n + 1 - d, (n + 1) / 2))
  list(r = floor(pos), gamma = pos - floor(pos)) # (1 - gamma) X_(r) + gamma X_(r+1)
}
se_imputed(c(min = 3, q1 = 10, med = 12, q3 = 15, max = 30), n = 30, "S3", type = hinges)
#> Imputed mean and SD under S3, n = 30, the BLUE, a user-supplied quantile rule
#>    mu_hat sigma_hat  se_naive     se_mu  se_sigma 
#>   12.9304    5.5706    1.0170    1.0527    0.8116 
#> Factors: C_mu(n) = 0.189, C_sigma(n) = 0.1457. The weights are $w_mean and $w_sd; every field with str() or unclass().
```
