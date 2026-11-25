# Blood urea nitrogen and hemoglobin in COVID-19 patients: ICU and non-ICU groups

Study summaries of two laboratory measures in COVID-19 patients, by
group: blood urea nitrogen (BUN, in mmol/L) in `bun_icu` and hemoglobin
(in g/L) in `hgb_icu`, seven studies each. Group 1 (suffix `.g1`) is the
ICU group and group 2 (suffix `.g2`) the non-ICU group, as the data
classify the patients. The studies come from the systematic review of
Katzenschlager et al. (2021), and the two data frames are those that
McGrath et al. (2023) published with their article, with the values and
the column names unchanged. In `bun_icu`, six studies report the three
quartiles of each group and one a sample mean and SD. In `hgb_icu`, five
report the quartiles and two a sample mean and SD. They are the data of
the two meta-analyses of Wu, Shi and Tong (2026), which
[`vignette("two-meta-analyses")`](https://zwulab.github.io/meta5number/articles/two-meta-analyses.md)
runs with this package.

## Usage

``` r
bun_icu

hgb_icu
```

## Format

Each a data frame with 7 rows and 13 columns, in the layout that
[`se_imputed_diff`](https://zwulab.github.io/meta5number/reference/se_imputed_diff.md)
reads with its default suffixes: `author`, the first author with the
journal, or "Preprint", in parentheses, as the source labels the study,
then for each group, with the suffix `.g1` or `.g2`, the columns `n`
(the sample size), `q1`, `med`, `q3` (the three quartiles), `mean` and
`sd` (the sample mean and SD), `NA` where the study does not report the
value.

An object of class `data.frame` with 7 rows and 13 columns.

## Source

The data frames `dat.BUN_ICU` and `dat.Hgb_ICU` of the repository
<https://github.com/stmcg/se-est>, which accompanies McGrath et al.
(2023), under the MIT license (copyright 2022 Sean McGrath). The license
notice is in the file `COPYRIGHTS` of the installed package.

## References

Katzenschlager S, Zimmer AJ, Gottschalk C, Grafeneder J, Schmitz S,
Kraker S, Ganslmeier M, Muth A, Seitel A, Maier-Hein L, Benedetti A,
Larmann J, Weigand MA, McGrath S, Denkinger CM (2021). Can we predict
the severe course of COVID-19 - a systematic review and meta-analysis of
indicators of clinical outcome? PLOS ONE 16(7), e0255154.

McGrath S, Katzenschlager S, Zimmer AJ, Seitel A, Steele R, Benedetti A
(2023). Standard error estimation in meta-analysis of studies reporting
medians. Statistical Methods in Medical Research 32(2), 373-388.

Wu Z, Shi J, Tong T (2026). Precision of the imputed mean and standard
deviation from the five-number summary. Manuscript.

## Examples

``` r
bun_icu
#>                     author n.g1 q1.g1 med.g1 q3.g1 mean.g1  sd.g1 n.g2 q1.g2
#> 1    Hong, Kyung Soo (YMJ)   13    NA     NA    NA    7.14 4.0698   85    NA
#> 2    Liu, Yanli (Preprint)   53  4.00   5.50  7.10      NA     NA   56  2.90
#> 3   Lei, Shaoqing (EClinM)   15  4.90   5.80 10.30      NA     NA   19  3.30
#> 4 Zhang, Guqin  (Preprint)   55  4.30   5.80  8.50      NA     NA  166  3.30
#> 5          Wang, Feng (EP)   14  7.20   9.20 11.30      NA     NA   14  3.00
#> 6       Wang, Dawei (JAMA)   36  4.30   5.90  9.60      NA     NA  102  3.10
#> 7      Cao, Min (Preprint)   19  3.53   4.54  8.23      NA     NA  171  3.54
#>   med.g2 q3.g2 mean.g2 sd.g2
#> 1     NA    NA  5.2122 3.213
#> 2   3.50  4.80      NA    NA
#> 3   4.00  4.20      NA    NA
#> 4   4.00  5.00      NA    NA
#> 5   5.00  5.50      NA    NA
#> 6   4.00  5.10      NA    NA
#> 7   4.47  5.56      NA    NA
# the difference of means, ICU minus non-ICU, with its naive and its exact
# standard error, for three studies (the vignette screens all seven by a
# skewness test and pools those that pass)
d <- se_imputed_diff(bun_icu[c(1, 5, 6), ])
d[, c("author", "scenario.g1", "yi", "sei_naive", "sei")]
#>                  author scenario.g1       yi sei_naive       sei
#> 1 Hong, Kyung Soo (YMJ)      sample 1.927800 1.1813337 1.1813337
#> 5       Wang, Feng (EP)          S2 4.795071 1.0516065 1.1144629
#> 6    Wang, Dawei (JAMA)          S2 2.582200 0.6968408 0.7453296
# the log of the SD ratio, ICU over non-ICU, with its two standard errors
h <- se_imputed_diff(hgb_icu[1:3, ], measure = "lnVR")
h[, c("author", "scenario.g1", "yi", "sei_naive", "sei")]
#>                            author scenario.g1          yi sei_naive       sei
#> 1         Huang, Chaolin (Lancet)          S2 -0.10163723 0.2467741 0.4002176
#> 2 Smadja, David M. (Angiogenesis)          S2 -0.28903251 0.2294157 0.3627600
#> 3           Hong, Kyung Soo (YMJ)      sample  0.06062462 0.2182179 0.2182179
```
