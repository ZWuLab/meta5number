# ==============================================================================
# File: test-covid.R
# Purpose: The data sets bun_icu and hgb_icu as published by their source, and the
#          two meta-analyses of the real-data section of Wu, Shi and Tong (2026)
#          (its Table 4) reproduced with the package: the mean difference of blood
#          urea nitrogen and the log SD ratio of hemoglobin, ICU against non-ICU,
#          on the studies that pass the skewness test of Shi et al. (2023), pooled
#          under the naive and the exact standard errors with the common-effect
#          model by pool_imputed() and with the REML random-effects model by
#          metafor. The expected values are the full-precision values that the
#          analysis behind that section wrote to its output files; the paper's
#          printed values follow by rounding.

tol <- 1e-6
fit_row <- function(f, r, cols) unlist(f$fits[r, cols], use.names = FALSE)

# the screening of the paper: a study leaves when the skewness test rejects
# normality in either group that reports the three quartiles
passes <- function(d) {
  rejects <- function(q1, med, q3, n) {
    stat <- abs(q1 + q3 - 2 * med) / (q3 - q1)
    !is.na(stat) & stat > 2.65 / sqrt(n) - 6 / n^2
  }
  !rejects(d$q1.g1, d$med.g1, d$q3.g1, d$n.g1) & !rejects(d$q1.g2, d$med.g2, d$q3.g2, d$n.g2)
}

# the REML fit with the control settings of the paper's analysis: the estimate,
# its standard error, tau^2 and I^2 in percent
reml <- function(yi, sei) {
  f <- metafor::rma(yi = yi, sei = sei, method = "REML", test = "z",
                    control = list(tau2.init = 0, stepadj = 0.25, maxiter = 1000, threshold = 1e-10))
  c(as.numeric(f$b), f$se, f$tau2, f$I2)
}

test_that("bun_icu and hgb_icu are the two data frames of the source", {
  cols <- c("author", paste0(rep(c("n", "q1", "med", "q3", "mean", "sd"), 2),
                             rep(c(".g1", ".g2"), each = 6)))
  for (d in list(bun_icu, hgb_icu)) {
    expect_s3_class(d, "data.frame")
    expect_equal(dim(d), c(7L, 13L))
    expect_identical(names(d), cols)
    # a group reports the three quartiles or a sample mean and SD, never both
    expect_true(all(is.na(d$med.g1) != is.na(d$mean.g1)))
    expect_true(all(is.na(d$med.g2) != is.na(d$mean.g2)))
  }
  expect_equal(bun_icu$n.g1, c(13, 53, 15, 55, 14, 36, 19))
  expect_equal(bun_icu$n.g2, c(85, 56, 19, 166, 14, 102, 171))
  expect_equal(sum(is.na(bun_icu$med.g1)), 1L)               # one study with a mean and SD
  expect_equal(sum(bun_icu$med.g1, na.rm = TRUE), 36.74)
  expect_equal(hgb_icu$n.g1, c(13, 20, 13, 117, 9, 14, 29))
  expect_equal(hgb_icu$n.g2, c(27, 20, 85, 423, 18, 14, 171))
  expect_equal(sum(is.na(hgb_icu$med.g1)), 2L)               # two studies with a mean and SD
  expect_equal(sum(hgb_icu$med.g2, na.rm = TRUE), 678)
})

test_that("the skewness test keeps five of the seven BUN studies and all hemoglobin studies", {
  expect_identical(passes(bun_icu), c(TRUE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE))
  expect_true(all(passes(hgb_icu)))
})

test_that("the BUN mean difference reproduces panel A of Table 4 of the paper", {
  d <- se_imputed_diff(bun_icu[passes(bun_icu), ])
  expect_identical(attr(d, "measure"), "MD")
  expect_equal(d$scenario.g1, c("sample", "S2", "S2", "S2", "S2"))
  expect_equal(d$yi, c(1.9277999, 2.12945052789817, 4.79507099350341, 2.58220004899257,
                       1.04910463755934), tolerance = tol)
  expect_equal(d$sei_naive^2, c(1.39554925679077, 0.195155121831897, 1.10587624263479,
                                0.485587137479585, 0.752298518132139), tolerance = tol)
  expect_equal(d$sei^2, c(1.39554925679077, 0.224338684724302, 1.24202745597819,
                          0.555516264330847, 0.848197701688574), tolerance = tol)
  # the common-effect fit: the paper prints 2.303 (1.688, 2.919) and 2.302 (1.647, 2.957)
  f <- pool_imputed(d)
  expect_identical(f$k, 5L)
  expect_equal(fit_row(f, "naive", c("estimate", "ci.lb", "ci.ub", "se")),
               c(2.30335110912882, 1.68765452398303, 2.91904769427461, 0.314136683123938), tolerance = tol)
  expect_equal(fit_row(f, "exact", c("estimate", "ci.lb", "ci.ub", "se")),
               c(2.30169223395181, 1.64685365607944, 2.95653081182419, 0.334107454543891), tolerance = tol)
  expect_equal(round(100 * (f$fits["exact", "se"] / f$fits["naive", "se"] - 1), 1), 6.4)   # the rise the paper quotes
  # the random-effects fit: the estimate, its SE, tau^2 and I^2
  skip_if_not_installed("metafor")
  expect_equal(reml(d$yi, d$sei_naive),
               c(2.40176940606835, 0.507917445425627, 0.637534051966124, 52.0779491148867), tolerance = 1e-5)
  expect_equal(reml(d$yi, d$sei),
               c(2.37374498568216, 0.469771133905005, 0.417212135958883, 38.8602958784219), tolerance = 1e-5)
})

test_that("the hemoglobin SD ratio reproduces panel B of Table 4 of the paper", {
  d <- se_imputed_diff(hgb_icu[passes(hgb_icu), ], measure = "lnVR")
  expect_identical(attr(d, "measure"), "lnVR")
  expect_equal(sum(d$scenario.g1 == "S2"), 5L)
  expect_equal(d$yi, c(-0.101637231342715, -0.289032511549652, 0.0606246218164348, 0.249901680460786,
                       -0.0884470011346795, 0.762140052046898, 0.175311012307737), tolerance = tol)
  expect_equal(d$sei^2, c(0.160174152949671, 0.13159483895516, 0.0476190476190476, 0.0149167333931071,
                          0.240242687240603, 0.187688093643167, 0.0207983193277311), tolerance = tol)
  # the common-effect fit, back-transformed: the paper prints 1.201 (1.075, 1.343) and 1.187 (1.016, 1.386)
  f <- pool_imputed(d)
  expect_equal(exp(fit_row(f, "naive", c("estimate", "ci.lb", "ci.ub"))),
               c(1.20146403102197, 1.07496367008314, 1.34285079395095), tolerance = tol)
  expect_equal(exp(fit_row(f, "exact", c("estimate", "ci.lb", "ci.ub"))),
               c(1.18686705612724, 1.01623283077089, 1.38615223427839), tolerance = tol)
  expect_equal(fit_row(f, c("naive", "exact"), "se"), c(0.056763274304696, 0.0791925890678599), tolerance = tol)
  # the random-effects fit: tau^2 is positive under the naive and zero under the exact standard errors,
  # where the fit is then the common-effect one
  skip_if_not_installed("metafor")
  rn <- reml(d$yi, d$sei_naive); re <- reml(d$yi, d$sei)
  expect_equal(c(exp(rn[1]), rn[2:4]),
               c(1.13779921369098, 0.0988138870990121, 0.0294333083331922, 48.4810580349218), tolerance = 1e-5)
  expect_equal(re[3], 0, tolerance = 1e-8)
  expect_equal(c(exp(re[1]), re[2]), c(1.18686705612724, 0.0791925890678599), tolerance = tol)
})
