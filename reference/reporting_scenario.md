# A data-reporting scenario with any set of quantiles

The named scenarios `"S1"` to `"S5"` cover a five-number summary, its
parts, and the 10th and 90th percentiles added to it. A study may report
other quantiles, for example the 5th and 95th percentiles, the tertiles,
or the median with one extreme. `reporting_scenario()` describes such a
report by the probabilities of its quantiles and by whether the minimum
and the maximum are reported. Its result is passed as the argument
`scenario` of
[`se_imputed`](https://zwulab.github.io/meta5number/reference/se_imputed.md),
[`c_mu`](https://zwulab.github.io/meta5number/reference/c_mu.md),
[`c_sigma`](https://zwulab.github.io/meta5number/reference/c_sigma.md),
[`inflation_factors`](https://zwulab.github.io/meta5number/reference/inflation_factors.md),
[`estimator_weights`](https://zwulab.github.io/meta5number/reference/estimator_weights.md)
and
[`imputed_moments`](https://zwulab.github.io/meta5number/reference/imputed_moments.md),
which then compute the BLUE of the mean and of the SD from these
reported values and its exact factors, at any sample size that is at
least the number of reported values.

## Usage

``` r
reporting_scenario(probs = numeric(0), min = FALSE, max = FALSE)

# S3 method for class 'reporting_scenario'
print(x, ...)
```

## Arguments

- probs:

  The probabilities of the reported sample quantiles, strictly between 0
  and 1 and strictly increasing, for example
  `c(0.05, 0.25, 0.5, 0.75, 0.95)`. May be empty when only the minimum
  and the maximum are reported.

- min, max:

  `TRUE` when the minimum, or the maximum, of the sample is reported.

- x:

  An object returned by `reporting_scenario()`.

- ...:

  Not used.

## Value

An object of class `"reporting_scenario"`: a list with `probs`, `min`,
`max` and `labels`, the names of the reported values in increasing order
(`min`, then `p5`, `p25`, ... for the quantiles, then `max`). The
weights that
[`estimator_weights`](https://zwulab.github.io/meta5number/reference/estimator_weights.md)
returns carry these names, and
[`se_imputed`](https://zwulab.github.io/meta5number/reference/se_imputed.md)
takes the reported values in this order.

## Details

At least two values must be reported, because the mean and the SD are
two unknowns. The reported values need not be symmetric about the
median. Only the BLUE is defined for such a scenario: the estimators of
Wan, Luo and Shi exist for S1, S2 and S3.

The named scenarios are special cases: `"S2"` gives the same weights and
factors as `reporting_scenario(c(0.25, 0.5, 0.75))`, and `"S5"` the same
as
`reporting_scenario(c(0.1, 0.25, 0.5, 0.75, 0.9), min = TRUE, max = TRUE)`.

How a study turned its sample into the reported quantiles is the
argument `type` of the functions that take the scenario: one of the nine
definitions of [`quantile`](https://rdrr.io/r/stats/quantile.html) or a
rule supplied as a function (see
[`imputed_moments`](https://zwulab.github.io/meta5number/reference/imputed_moments.md)).

Assumptions: an i.i.d. normal sample, as everywhere in the package.

## References

Wu Z, Shi J, Tong T (2026). Precision of the imputed mean and standard
deviation from a five-number summary. Manuscript.

## See also

[`se_imputed`](https://zwulab.github.io/meta5number/reference/se_imputed.md),
[`imputed_moments`](https://zwulab.github.io/meta5number/reference/imputed_moments.md)

## Examples

``` r
# a study reports the median with the 5th and 95th percentiles, n = 60
sc <- reporting_scenario(c(0.05, 0.5, 0.95))
sc
#> Reporting scenario with 3 reported values: p5, p50, p95
#> Quantiles at the probabilities 0.05, 0.50, 0.95
inflation_factors(60, sc)                       # the exact IFs of the BLUE
#>    kappa_mu kappa_sigma 
#>    1.089587    1.212702 
se_imputed(c(2.1, 5.0, 8.4), n = 60, scenario = sc)
#> Imputed mean and SD under the reported values (p5, p50, p95), n = 60, the BLUE, quantile type 7
#>    mu_hat sigma_hat  se_naive     se_mu  se_sigma 
#>    5.0961    2.0124    0.2598    0.2831    0.2242 
#> Factors: C_mu(n) = 0.1407, C_sigma(n) = 0.1114. The weights are $w_mean and $w_sd; every field with str() or unclass().

# the 10th and 90th percentiles with the quartiles: the named scenario S4
s4 <- reporting_scenario(c(0.1, 0.25, 0.5, 0.75, 0.9))
all.equal(c_mu(41, s4), c_mu(41, "S4"))
#> [1] TRUE

# the minimum, the median and the third quartile only
c_sigma(30, reporting_scenario(c(0.5, 0.75), min = TRUE))
#> [1] 0.186472
```
