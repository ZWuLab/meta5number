# ==============================================================================
# File: sdf_shortcut.R
# Purpose: The shortcut formulas for the SDFs, closed forms in n with the constants as the
#          paper prints them, for the BLUE and for the estimators of Wan, Luo and
#          Shi, and the kept copy of the former formulas for the studies run with them.
#
# EXPORTED FUNCTIONS:
#   - c_mu_shortcut()     shortcut formula for c_mu(), version "blue" or "wan_luo_shi"
#   - c_sigma_shortcut()  shortcut formula for c_sigma(), version "blue" or "wan_luo_shi"
#
# INTERNAL HELPERS:
#   - .sdf_formula_former()  the formulas as printed until 2026-10-04
#   - .xlog()             k * log(v) with the k = 0 guard

#################### EXPORTED MAIN FUNCTIONS ####################

#' Shortcut formula for C_mu(n)
#'
#' Closed-form shortcut formula
#' \eqn{C_\mu(n) \approx A/\sqrt{n + c_1 \log n + c_2}} for the exact
#' \code{\link{c_mu}}, in the style of Wan's \eqn{\xi_B(n)} and Luo's
#' \eqn{w_{opt}(n)} formulas. The leading constant \eqn{A} is the limit of
#' \eqn{\sqrt{n}\,C_\mu(n)} (Theorem 1 of Wu, Shi and Tong, 2026) rounded to four decimals:
#' \eqn{\sqrt{\pi/2}} under S1 and \eqn{\sqrt{v}} under S2 and S3. The term
#' \eqn{c_1 \log n} stands for the precision that the minimum and maximum add,
#' which is of order \eqn{\log n} against order \eqn{n} from the central order
#' statistics; under S2 no extreme is reported and \eqn{c_1 = 0}. This reason
#' is the BLUE's; for the Wan-Luo-Shi version the same form is an empirical fit. Two
#' constant sets are carried: \code{version = "blue"} (the default) for the factor of
#' the BLUE, the default estimator version of Wu, Shi and Tong (2026), and
#' \code{version = "wan_luo_shi"} for the factor of Luo's mean estimator. Both are fitted by minimax
#' relative error over the paper's 39-point grid of \eqn{n = 4Q+1} (every such \eqn{n} from 5 to 101 and 14
#' larger ones up to 1001), and are used here exactly as the paper prints
#' them (A to four decimals, the c's to three), so that the software and the
#' paper carry the same formula. The errors below are those of the printed
#' constants, on the grid and at \eqn{n = 2001, 5001, 10001} beyond it,
#' computed by the fitting script. The formulas serve a reader without this
#' package and a comparison with the exact values; \code{\link{c_mu}} computes the
#' exact factor at every \eqn{n}, and \code{\link{se_imputed}} uses it.
#'
#' @param n Integer sample size(s); vectorized. The formulas are continuous in
#'   \eqn{n} and are applied at any \eqn{n}, as the source papers apply theirs.
#'   Each tends to its limit as \eqn{n} grows, so no upper bound on \eqn{n} is
#'   checked.
#' @param scenario One of "S1", "S2", "S3".
#' @param version \code{"blue"} (default) or \code{"wan_luo_shi"}: which estimator
#'   version's factor the formula approximates.
#' @return Numeric vector of approximate \eqn{C_\mu(n)} values.
#' @details
#' Fitted forms and accuracy (relative error against the exact factor), BLUE:
#' \itemize{
#' \item S1: \eqn{1.2533/\sqrt{n + 2.00\log n - 0.80}}; error \eqn{\le 0.35\%}
#'   on the grid and \eqn{\le 0.078\%} at \eqn{n = 2001, 5001, 10001}.
#' \item S2: \eqn{1.0780/\sqrt{n + 0.14}}; error \eqn{\le 0.065\%}
#'   on the grid and \eqn{\le 0.002\%} at \eqn{n = 2001, 5001, 10001}.
#' \item S3: \eqn{1.0780/\sqrt{n + 0.84\log n - 0.58}}; error \eqn{\le 0.34\%}
#'   on the grid and \eqn{\le 0.081\%} at \eqn{n = 2001, 5001, 10001}.
#' }
#' Shortcut version (Luo's shortcut mean):
#' \itemize{
#' \item S1: \eqn{1.2533/\sqrt{n + 2.00\log n - 0.80}}; error \eqn{\le 0.35\%}
#'   on the grid and \eqn{\le 0.058\%} at \eqn{n = 2001, 5001, 10001}.
#' \item S2: \eqn{1.0780/\sqrt{n + 0.14}}; error \eqn{\le 0.065\%}
#'   on the grid and \eqn{\le 0.002\%} at \eqn{n = 2001, 5001, 10001}.
#' \item S3: \eqn{1.0780/\sqrt{n + 0.83\log n - 0.56}}; error \eqn{\le 0.34\%}
#'   on the grid and \eqn{\le 0.081\%} at \eqn{n = 2001, 5001, 10001}.
#' }
#' Assumptions: iid normal data. The errors are measured on the grid of
#' \eqn{n = 4Q+1}, where the quartiles are single order statistics (type 7), and
#' at the three larger sizes named; they are not bounds for every \eqn{n}.
#' \code{\link{c_mu}} computes the exact factor at any \eqn{n} and definition.
#' @examples
#' c_mu_shortcut(25, "S2")
#' c_mu_shortcut(25, "S2", version = "wan_luo_shi")
#' c_mu_shortcut(5000, "S3")        # no upper limit on n
#' @references
#' Wu Z, Shi J, Tong T (2026). Precision of the imputed mean and standard
#' deviation from a five-number summary. Manuscript.
#' @export
c_mu_shortcut <- function(n, scenario = c("S3", "S1", "S2"), version = c("blue", "wan_luo_shi")) {
  scenario <- match.arg(scenario); version <- match.arg(version)
  # Constants as Wu, Shi and Tong (2026) print them (their Table 3 for the BLUE, their supplement table
  # for the Wan-Luo-Shi version): A is the limit of sqrt(n) C_mu(n) to four decimals
  # (sqrt(pi/2) under S1; sqrt(v) under S2 and S3, and sqrt(v-tilde) of the
  # Wan-Luo-Shi version prints the same), c1 multiplies log n (zero under S2, where
  # no extreme is reported), c2 is the additive constant.
  co <- switch(version,
    blue = switch(scenario,
      S1 = c(A = 1.2533, c1 = 2.00, c2 = -0.80),
      S2 = c(A = 1.0780, c1 = 0,     c2 = 0.14),
      S3 = c(A = 1.0780, c1 = 0.84, c2 = -0.58)),
    wan_luo_shi = switch(scenario,
      S1 = c(A = 1.2533, c1 = 2.00, c2 = -0.80),
      S2 = c(A = 1.0780, c1 = 0,     c2 = 0.14),
      S3 = c(A = 1.0780, c1 = 0.83, c2 = -0.56)))
  if (any(n < 5))
    warning("c_mu_shortcut() was fitted on n >= 5; extrapolating below.")
  as.numeric(co["A"] / sqrt(n + co["c1"] * log(n) + co["c2"]))
}

#' Shortcut formula for C_sigma(n)
#'
#' Closed-form shortcut formula for the exact \code{\link{c_sigma}}. The form
#' differs by scenario for a structural reason. Under S2 and S3
#' \eqn{n\,C^2_\sigma(n)} has the finite limit \eqn{h} (Theorem 1 of Wu, Shi and Tong, 2026),
#' so the formula is \eqn{A/\sqrt{n + \dots}} with \eqn{A = \sqrt{h}} rounded to
#' four decimals. Under S3 the minimum and maximum add precision of order
#' \eqn{(\log n)^2}, against order \eqn{n} from the quartiles, which the terms
#' \eqn{c_1(\log n)^2 + c_2\log n} stand for. Under S1 the range-based factor
#' has no such limit and decays only like \eqn{1/\log n}, so the formula is the
#' logarithmic \eqn{c_1/(\log n + c_2)^{c_3}}. Two constant sets are carried:
#' \code{version = "blue"} (the default) for the factor of the BLUE of
#' \eqn{\sigma}, and \code{version = "wan_luo_shi"} for the factor of the SD
#' estimators of Wan (under S1 and S2) and Shi (under S3). Both are fitted by
#' minimax relative error over the paper's 40-point grid of \eqn{n = 4Q+1}
#' (every such \eqn{n} from 5 to 101 and 15 larger ones up to 1001), with the
#' constants exactly as the paper prints them: the anchors to four decimals, the
#' fitted constants to two.
#'
#' @param n Integer sample size(s); vectorized. Applied at any \eqn{n}, as the
#'   source papers apply their formulas. No upper bound on \eqn{n} is checked;
#'   see Details for the accuracy beyond the grid.
#' @param scenario One of "S1", "S2", "S3".
#' @param version \code{"blue"} (default) or \code{"wan_luo_shi"}.
#' @return Numeric vector of approximate \eqn{C_\sigma(n)} values.
#' @details
#' Accuracy is the relative error of the printed constants against the exact
#' factor, on the grid and at \eqn{n = 2001, 5001, 10001} beyond it. BLUE:
#' \itemize{
#' \item S1: \eqn{0.84/(\log n + 0.35)^{1.21}}; error \eqn{\le 0.39\%} on
#'   the grid, and \eqn{-0.8\%}, \eqn{-1.5\%}, \eqn{-2.1\%} at
#'   \eqn{n = 2001, 5001, 10001}: this formula has no limit to hold it, and its
#'   error grows slowly beyond the grid.
#' \item S2: \eqn{1.1664/\sqrt{n - 0.87}}; error \eqn{\le 0.16\%} on the grid
#'   and \eqn{\le 0.003\%} beyond.
#' \item S3: \eqn{1.1664/\sqrt{n + 5.26(\log n)^2 - 10.33\log n + 8.29}};
#'   error \eqn{\le 0.43\%} on the grid and \eqn{\le 0.33\%} beyond.
#' }
#' Shortcut version:
#' \itemize{
#' \item S1: \eqn{0.87/(\log n + 0.42)^{1.22}}; error \eqn{\le 0.50\%} on
#'   the grid, and \eqn{-0.9\%}, \eqn{-1.6\%}, \eqn{-2.1\%} at
#'   \eqn{n = 2001, 5001, 10001}: this formula has no limit to hold it, and its
#'   error grows slowly beyond the grid.
#' \item S2: \eqn{1.1664/\sqrt{n - 0.84}}; error \eqn{\le 0.12\%} on the grid
#'   and \eqn{\le 0.001\%} beyond.
#' \item S3: \eqn{1.1664/\sqrt{n + 5.19(\log n)^2 - 10.20\log n + 8.52}};
#'   error \eqn{\le 0.44\%} on the grid and \eqn{\le 0.27\%} beyond.
#' }
#' Assumptions: iid normal data. The errors are measured on the grid of
#' \eqn{n = 4Q+1}, where the quartiles are single order statistics (type 7), and
#' at the three larger sizes named; they are not bounds for every \eqn{n}.
#' \code{\link{c_sigma}} computes the exact factor at any \eqn{n} and definition.
#' @examples
#' c_sigma_shortcut(25, "S2")
#' c_sigma_shortcut(5000, "S3")    # no upper limit on n
#' @references
#' Wu Z, Shi J, Tong T (2026). Precision of the imputed mean and standard
#' deviation from a five-number summary. Manuscript.
#' @export
c_sigma_shortcut <- function(n, scenario = c("S3", "S1", "S2"), version = c("blue", "wan_luo_shi")) {
  scenario <- match.arg(scenario); version <- match.arg(version)
  # Constants as Wu, Shi and Tong (2026) print them (their Table 3 for the BLUE, their supplement table
  # for the Wan-Luo-Shi version). S2 and S3: A / sqrt(n + c1 (log n)^2 + c2 log n + c3)
  # with A = sqrt(h) to four decimals and c1 = c2 = 0 under S2 (no extreme is
  # reported). S1: the log-power form c1 / (log n + c2)^c3.
  co <- switch(version,
    blue = switch(scenario,
      S1 = c(c1 = 0.84, c2 = 0.35, c3 = 1.21),
      S2 = c(A = 1.1664, c1 = 0,     c2 = 0,       c3 = -0.87),
      S3 = c(A = 1.1664, c1 = 5.26, c2 = -10.33, c3 = 8.29)),
    wan_luo_shi = switch(scenario,
      S1 = c(c1 = 0.87, c2 = 0.42, c3 = 1.22),
      S2 = c(A = 1.1664, c1 = 0,     c2 = 0,       c3 = -0.84),
      S3 = c(A = 1.1664, c1 = 5.19, c2 = -10.20, c3 = 8.52)))
  if (any(n < 5))
    warning("c_sigma_shortcut() was fitted on n >= 5; extrapolating below.")
  L <- log(n)
  if (scenario == "S1") return(as.numeric(co["c1"] / (L + co["c2"])^co["c3"]))
  as.numeric(co["A"] / sqrt(n + co["c1"] * L^2 + co["c2"] * L + co["c3"]))
}

#################### INTERNAL HELPER FUNCTIONS ####################

#' The shortcut formulas for the factors as first printed
#'
#' The former \code{c_mu_shortcut()} and \code{c_sigma_shortcut()}: \eqn{A/(n + B)^E},
#' or \eqn{A/(\log n + B)^E} for the SD under S1, fitted on
#' \eqn{n = 4Q+1 \in [5, 101]}. Kept, unexported, for two uses only: the earlier
#' studies that were run with these constants call it so that they reproduce
#' exactly, and the fit of the current formulas compares the former ones with
#' them. New work uses
#' \code{\link{c_mu_shortcut}} and \code{\link{c_sigma_shortcut}}. Unlike the former
#' functions it gives no warning outside the range on which it was fitted,
#' where its error grows (to 6.6\% at \eqn{n = 1001} for the mean under S1).
#' @param n Sample size(s); vectorized.
#' @param scenario One of "S1", "S2", "S3".
#' @param factor \code{"mu"} for \eqn{C_\mu(n)} or \code{"sd"} for \eqn{C_\sigma(n)}.
#' @param version \code{"blue"} or \code{"wan_luo_shi"}.
#' @return Numeric vector, the former formula's value.
#' @keywords internal
#' @noRd
.sdf_formula_former <- function(n, scenario = c("S3", "S1", "S2"), factor = c("mu", "sd"),
                                version = c("blue", "wan_luo_shi")) {
  scenario <- match.arg(scenario); factor <- match.arg(factor); version <- match.arg(version)
  # constants A, B, E exactly as first fitted
  co <- list(
    blue = list(mu = list(S1 = c(0.9966, 0.470, 0.4586), S2 = c(1.0780, 0.142, 0.5), S3 = c(0.9864, 0.124, 0.4846)),
                sd = list(S1 = c(0.9446, 0.478, 1.2662), S2 = c(1.1664, -0.863, 0.5), S3 = c(0.5667, -2.073, 0.4052))),
    wan_luo_shi = list(mu = list(S1 = c(0.9973, 0.475, 0.4588), S2 = c(1.0780, 0.142, 0.5), S3 = c(0.9821, 0.076, 0.4837)),
                    sd = list(S1 = c(1.0040, 0.580, 1.2860), S2 = c(1.1664, -0.845, 0.5), S3 = c(0.5671, -1.971, 0.4047)))
  )[[version]][[factor]][[scenario]]
  base <- if (factor == "sd" && scenario == "S1") log(n) + co[2] else n + co[2]   # log-power for the SD under S1
  co[1] / base^co[3]
}

#' k * log(v), returning 0 when k = 0 (guards 0 * -Inf = NaN)
#' @keywords internal
#' @noRd
.xlog <- function(k, logv) if (k == 0) 0 else k * logv
