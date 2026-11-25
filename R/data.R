# ==============================================================================
# File: data.R
# Purpose: Documentation of the data sets: bun_icu and hgb_icu, the study summaries
#          of the two COVID-19 meta-analyses of Wu, Shi and Tong (2026), and vitd,
#          the six studies of the vitamin D meta-analysis of Nnoaham and Clarke
#          (2008).

#' Blood urea nitrogen and hemoglobin in COVID-19 patients: ICU and non-ICU groups
#'
#' Study summaries of two laboratory measures in COVID-19 patients, by group:
#' blood urea nitrogen (BUN, in mmol/L) in \code{bun_icu} and hemoglobin (in
#' g/L) in \code{hgb_icu}, seven studies each. Group 1 (suffix \code{.g1}) is the ICU
#' group and group 2 (suffix \code{.g2}) the non-ICU group, as the data classify
#' the patients. The studies come from the systematic review of Katzenschlager et
#' al. (2021), and the two data frames are those that McGrath et al. (2023)
#' published with their article, with the values and the column names unchanged.
#' In \code{bun_icu}, six studies report the three quartiles of each group and
#' one a sample mean and SD. In \code{hgb_icu}, five report the quartiles and two
#' a sample mean and SD. They are the data of the two meta-analyses of Wu, Shi
#' and Tong (2026), which \code{vignette("two-meta-analyses")} runs with this
#' package.
#'
#' @format Each a data frame with 7 rows and 13 columns, in the layout that
#'   \code{\link{se_imputed_diff}} reads with its default suffixes:
#'   \code{author}, the first author with the journal, or "Preprint", in
#'   parentheses, as the source labels the study, then for each group, with the suffix \code{.g1}
#'   or \code{.g2}, the columns \code{n} (the sample size), \code{q1},
#'   \code{med}, \code{q3} (the three quartiles), \code{mean} and \code{sd}
#'   (the sample mean and SD), \code{NA} where the study does not report the
#'   value.
#' @source The data frames \code{dat.BUN_ICU} and \code{dat.Hgb_ICU} of the
#'   repository \url{https://github.com/stmcg/se-est}, which accompanies McGrath
#'   et al. (2023), under the MIT license (copyright 2022 Sean McGrath). The
#'   license notice is in the file \code{COPYRIGHTS} of the installed package.
#' @references
#' Katzenschlager S, Zimmer AJ, Gottschalk C, Grafeneder J, Schmitz S, Kraker S,
#' Ganslmeier M, Muth A, Seitel A, Maier-Hein L, Benedetti A, Larmann J, Weigand
#' MA, McGrath S, Denkinger CM (2021). Can we predict the severe course of
#' COVID-19 - a systematic review and meta-analysis of indicators of clinical
#' outcome? PLOS ONE 16(7), e0255154.
#'
#' McGrath S, Katzenschlager S, Zimmer AJ, Seitel A, Steele R, Benedetti A
#' (2023). Standard error estimation in meta-analysis of studies reporting
#' medians. Statistical Methods in Medical Research 32(2), 373-388.
#'
#' Wu Z, Shi J, Tong T (2026). Precision of the imputed mean and standard
#' deviation from the five-number summary. Manuscript.
#' @examples
#' bun_icu
#' # the difference of means, ICU minus non-ICU, with its naive and its exact
#' # standard error, for three studies (the vignette screens all seven by a
#' # skewness test and pools those that pass)
#' d <- se_imputed_diff(bun_icu[c(1, 5, 6), ])
#' d[, c("author", "scenario.g1", "yi", "sei_naive", "sei")]
#' # the log of the SD ratio, ICU over non-ICU, with its two standard errors
#' h <- se_imputed_diff(hgb_icu[1:3, ], measure = "lnVR")
#' h[, c("author", "scenario.g1", "yi", "sei_naive", "sei")]
"bun_icu"

#' @rdname bun_icu
"hgb_icu"

#' Serum vitamin D in tuberculosis cases and controls: six studies
#'
#' The six studies of the meta-analysis of serum vitamin D (nmol/L) in
#' tuberculosis cases against controls of Nnoaham and Clarke (2008), typed from
#' their Table 1. Three studies report the median, minimum and maximum of each
#' group (Davies, UK; Grange, Indonesia; Davies, Kenya: the scenario \code{"S1"}
#' of \code{\link{se_imputed_df}}), two a sample mean and SD (Davies, Thailand;
#' Chan, Hong Kong: \code{"sample"}), and one a sample mean with the minimum and
#' maximum (Sasidharan, India: \code{"mean_range"}, the mean kept and the SD
#' imputed from the range). The same six studies are the real-data example
#' of Luo et al. (2018) and of Yang, Hutson and Wang (2022). They serve here
#' as example data for the scenarios \code{"S1"} and \code{"mean_range"}.
#'
#' @format A data frame with 6 rows and 13 columns: \code{study}, the first
#'   author and the country, as the source labels the study, then for each
#'   group, with the suffix \code{.cases} or \code{.controls}, the columns
#'   \code{n} (the sample size), \code{min}, \code{med}, \code{max} (the
#'   minimum, the median, the maximum), \code{mean} and \code{sd} (the sample
#'   mean and SD), \code{NA} where the study does not report the value.
#' @source Nnoaham KE, Clarke A (2008). Low serum vitamin D levels and
#'   tuberculosis: a systematic review and meta-analysis. International Journal
#'   of Epidemiology 37(1), 113-119, Table 1. Chan et al. has 22 cases and 23
#'   controls there, in Table 5 of Yang et al. (2022) and in Tables 2 and 3 of
#'   Luo et al. (2018), whose Table 1 prints 24 and 24.
#' @references
#' Luo D, Wan X, Liu J, Tong T (2018). Optimally estimating the sample mean from
#' the sample size, median, mid-range, and/or mid-quartile range. Statistical
#' Methods in Medical Research 27(6), 1785-1805.
#'
#' Yang X, Hutson AD, Wang D (2022). A generalized BLUE approach for combining
#' location and scale information in a meta-analysis. Journal of Applied
#' Statistics 49(15), 3846-3867.
#' @examples
#' vitd
#' # the difference of means, controls minus cases, with its naive and its exact
#' # standard error, and the pooled difference under each
#' d <- se_imputed_diff(vitd, suffixes = c(".controls", ".cases"))
#' d[, c("study", "scenario.cases", "yi", "sei_naive", "sei")]
#' pool_imputed(d)
"vitd"
