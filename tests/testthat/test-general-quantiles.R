# ==============================================================================
# File: test-general-quantiles.R
# Purpose: Any set of reported quantiles and a user-supplied quantile rule:
#          (1) the named scenarios S1 to S5 are special cases of reporting_scenario();
#          (2) at sample sizes where every reported quantile is one order statistic, the
#              weights and factors equal the engine's own BLUE, orderStatMoments::os_blue(),
#              for a symmetric and for an asymmetric set of quantiles;
#          (3) at a large sample size the inflation factors approach the limits of the
#              companion paper's corollary on more reported quantiles;
#          (4) a rule written from the formulas of Hyndman and Fan (1996) reproduces each
#              of the nine definitions;
#          (5) Tukey's hinges written as a rule reproduce stats::fivenum(), and their
#              factors are those of the definition they coincide with at that n;
#          (6) a simulation agrees with the exact factors for an asymmetric scenario with
#              one extreme;
#          (7) se_imputed() reads the reported values named or in order;
#          (8) the inputs are checked;
#          (9) further cases: an object edited by hand, a
#              `type` given with no quantile reported, rounding residues of a rule, the
#              smallest sample size, the messages.

# the named scenarios written as reporting_scenario() objects
as_custom <- list(
  S1 = reporting_scenario(0.5, min = TRUE, max = TRUE),
  S2 = reporting_scenario(c(0.25, 0.5, 0.75)),
  S3 = reporting_scenario(c(0.25, 0.5, 0.75), min = TRUE, max = TRUE),
  S4 = reporting_scenario(c(0.1, 0.25, 0.5, 0.75, 0.9)),
  S5 = reporting_scenario(c(0.1, 0.25, 0.5, 0.75, 0.9), min = TRUE, max = TRUE))

# the nine definitions of Hyndman and Fan (1996) as a rule (p, n) -> (r, gamma): the
# position is n p + m with m = 0, 0, -1/2 for types 1 to 3 and m = a + p (1 - a - b)
# for the continuous types 4 to 9, clipped to the sample
hf_rule <- function(type) function(p, n) {
  m <- switch(type, 0, 0, -0.5, 0, 0.5, p, 1 - p, (p + 1) / 3, p / 4 + 3 / 8)
  pos <- n * p + m
  j <- floor(pos + 4 * .Machine$double.eps); g <- pos - j
  g[abs(g) < 1e-9] <- 0
  if (type == 1) g <- as.numeric(g > 0)                     # the next order statistic
  if (type == 2) g <- ifelse(g > 0, 1, 0.5)                 # averaging at a discontinuity
  if (type == 3) g <- ifelse(g == 0 & j %% 2 == 0, 0, 1)    # the nearest even order statistic
  r <- j
  low <- r < 1; r[low] <- 1; g[low] <- 0                    # below the first order statistic
  high <- r >= n; r[high] <- n; g[high] <- 0                # above the last
  list(r = r, gamma = g)
}

# Tukey's hinges, the quartiles of stats::fivenum(): the lower hinge at position
# d = (floor((n + 1) / 2) + 1) / 2, the upper at n + 1 - d
hinges <- function(p, n) {
  d <- (floor((n + 1) / 2) + 1) / 2
  pos <- ifelse(p < 0.5, d, ifelse(p > 0.5, n + 1 - d, (n + 1) / 2))
  list(r = floor(pos), gamma = pos - floor(pos))
}

test_that("the named scenarios are special cases of reporting_scenario()", {
  for (sc in names(as_custom)) for (n in c(21L, 30L, 44L)) for (type in c(7, 6, 2)) {
    cu <- as_custom[[sc]]
    for (est in c("mean", "sd"))
      expect_equal(unname(estimator_weights(n, cu, est, type = type)),
                   unname(estimator_weights(n, sc, est, type = type)), tolerance = 1e-12)
    expect_equal(c_mu(n, cu, type = type), c_mu(n, sc, type = type), tolerance = 1e-12)
    expect_equal(c_sigma(n, cu, type = type), c_sigma(n, sc, type = type), tolerance = 1e-12)
    expect_equal(inflation_factors(n, cu, type = type), inflation_factors(n, sc, type = type),
                 tolerance = 1e-12)
  }
  # the same estimates from the same reported values
  q <- c(min = 3, p10 = 6, q1 = 10, med = 12, q3 = 15, p90 = 21, max = 30)
  a <- se_imputed(q, 41L, "S5"); b <- se_imputed(unname(q), 41L, as_custom$S5)
  for (f in c("mu_hat", "sigma_hat", "se_naive", "se_mu", "se_sigma", "c_n", "c_sigma"))
    expect_equal(b[[f]], a[[f]], tolerance = 1e-12)
})

test_that("at exact ranks the weights and factors are those of the engine's own BLUE", {
  # under type 7 the quantile at p is the order statistic at rank (n - 1) p + 1 when that
  # is a whole number: a symmetric set at n = 41 and an asymmetric one at n = 21
  cases <- list(list(n = 41L, sc = reporting_scenario(c(0.05, 0.25, 0.5, 0.75, 0.95)),
                     ranks = c(3L, 11L, 21L, 31L, 39L)),
                list(n = 21L, sc = reporting_scenario(c(0.05, 0.5, 0.8)), ranks = c(2L, 11L, 17L)),
                list(n = 21L, sc = reporting_scenario(c(0.5, 0.8), min = TRUE), ranks = c(1L, 11L, 17L)),
                list(n = 21L, sc = reporting_scenario(c(0.05, 0.5), max = TRUE), ranks = c(2L, 11L, 21L)))
  for (cs in cases) {
    im <- imputed_moments(cs$n, cs$sc)
    expect_identical(im$ranks, cs$ranks)
    bl <- orderStatMoments::os_blue(orderStatMoments::os_moments(cs$n, cs$ranks))
    expect_equal(unname(im$w_mean), unname(bl$w_mu), tolerance = 1e-10)
    expect_equal(unname(im$w_sd), unname(bl$w_sigma), tolerance = 1e-10)
    expect_equal(c_mu(cs$n, cs$sc)^2, bl$var_mu, tolerance = 1e-10)
    expect_equal(c_sigma(cs$n, cs$sc)^2, bl$var_sigma, tolerance = 1e-10)
    expect_equal(im$cov, bl$cov, tolerance = 1e-9)
    # unbiased: the weights of the mean sum to one and are orthogonal to alpha, and so on
    expect_lt(max(abs(im$gaps)), 1e-10)
  }
})

test_that("the inflation factors approach the limits of the corollary on more reported quantiles", {
  skip_on_cran()
  # the limits (1 / 1'G^{-1}1)^{1/2} and (2 / zeta'G^{-1}zeta)^{1/2}, with
  # G_jl = {min(p_j, p_l) - p_j p_l} / {phi(zeta_j) phi(zeta_l)} and zeta_j = qnorm(p_j)
  lim <- function(p) {
    z <- qnorm(p); G <- (outer(p, p, pmin) - outer(p, p)) / outer(dnorm(z), dnorm(z))
    Gi <- solve(G); one <- rep(1, length(p))
    c(sqrt(1 / drop(one %*% Gi %*% one)), sqrt(2 / drop(z %*% Gi %*% z)))
  }
  p <- c(0.1, 0.25, 0.5, 0.75, 0.9)
  expect_equal(lim(p), c(1.0322, 1.2036), tolerance = 5e-5)   # the values the paper prints
  expect_equal(unname(inflation_factors(20001L, reporting_scenario(p))), lim(p), tolerance = 1e-3)
  p <- c(0.05, 0.25, 0.5, 0.75, 0.95)
  expect_equal(unname(inflation_factors(20001L, reporting_scenario(p))), lim(p), tolerance = 1e-3)
})

test_that("a rule written from the formulas of Hyndman and Fan reproduces each definition", {
  for (type in 1:9) for (n in c(12L, 23L, 30L)) {
    # the rule gives the quantiles of stats::quantile() on a sample
    set.seed(100 * type + n); x <- sort(rnorm(n)); p <- c(0.1, 0.25, 0.5, 0.75, 0.9)
    ru <- hf_rule(type)(p, n)
    expect_equal((1 - ru$gamma) * x[ru$r] + ru$gamma * x[pmin(ru$r + 1L, n)],
                 unname(quantile(x, p, type = type)), tolerance = 1e-12)
    # and the same factors as the definition's number
    for (sc in c("S2", "S3")) {
      expect_equal(c_mu(n, sc, type = hf_rule(type)), c_mu(n, sc, type = type), tolerance = 1e-10)
      expect_equal(c_sigma(n, sc, type = hf_rule(type)), c_sigma(n, sc, type = type),
                   tolerance = 1e-10)
    }
  }
  expect_equal(c_sigma(30L, as_custom$S4, type = hf_rule(6)), c_sigma(30L, "S4", type = 6),
               tolerance = 1e-10)
})

test_that("Tukey's hinges as a rule reproduce fivenum() and the factors of the matching definition", {
  for (n in 5:24) {
    set.seed(n); x <- sort(rnorm(n)); h <- hinges(c(0.25, 0.5, 0.75), n)
    expect_equal((1 - h$gamma) * x[h$r] + h$gamma * x[pmin(h$r + 1L, n)], fivenum(x)[2:4],
                 tolerance = 1e-12)
  }
  # the hinges are the quartiles of type 2 except at n = 4m + 3, where they are those of
  # type 7 (checked on the samples above), so no one definition gives them at every n
  for (n in c(20L, 21L, 22L)) for (sc in c("S2", "S3"))
    expect_equal(c_sigma(n, sc, type = hinges), c_sigma(n, sc, type = 2), tolerance = 1e-10)
  for (sc in c("S2", "S3")) {
    expect_equal(c_sigma(23L, sc, type = hinges), c_sigma(23L, sc, type = 7), tolerance = 1e-10)
    expect_gt(abs(c_sigma(23L, sc, type = hinges) - c_sigma(23L, sc, type = 2)), 1e-5)
  }
  r <- se_imputed(c(min = 3, q1 = 10, med = 12, q3 = 15, max = 30), n = 30L, "S3", type = hinges)
  expect_true(is.function(r$type))
  expect_output(print(r), "a user-supplied quantile rule")
})

test_that("a simulation agrees with the exact factors of an asymmetric scenario", {
  skip_on_cran()
  # the minimum with the 10th percentile, the median and the 80th percentile, n = 30, type 7
  n <- 30L; N <- 20000L; p <- c(0.1, 0.5, 0.8); sc <- reporting_scenario(p, min = TRUE)
  wm <- estimator_weights(n, sc, "mean"); ws <- estimator_weights(n, sc, "sd")
  expect_named(wm, c("min", "p10", "p50", "p80"))
  set.seed(20261118)
  mu0 <- 10; sig0 <- 3
  est <- t(vapply(seq_len(N), function(i) {
    x <- rnorm(n, mu0, sig0); y <- c(min(x), quantile(x, p, type = 7, names = FALSE))
    c(sum(wm * y), sum(ws * y))
  }, numeric(2)))
  # the Monte Carlo standard error of an empirical SD is about SD / sqrt(2N), and that of a
  # mean SD / sqrt(N); four standard errors each
  expect_lt(abs(sd(est[, 1]) / sig0 / c_mu(n, sc) - 1), 4 / sqrt(2 * N))
  expect_lt(abs(sd(est[, 2]) / sig0 / c_sigma(n, sc) - 1), 4 / sqrt(2 * N))
  expect_lt(abs(mean(est[, 1]) - mu0), 4 * sig0 * c_mu(n, sc) / sqrt(N))      # unbiased for mu
  expect_lt(abs(mean(est[, 2]) - sig0), 4 * sig0 * c_sigma(n, sc) / sqrt(N))  # and for sigma
})

test_that("se_imputed() reads the reported values of a reporting_scenario() named or in order", {
  sc <- reporting_scenario(c(0.05, 0.5, 0.95))
  a <- se_imputed(c(2.1, 5.0, 8.4), n = 60L, scenario = sc)
  b <- se_imputed(c(p95 = 8.4, p5 = 2.1, p50 = 5.0, extra = 1), n = 60L, scenario = sc)
  expect_equal(b$mu_hat, a$mu_hat); expect_equal(b$se_sigma, a$se_sigma)
  expect_equal(a$mu_hat, sum(a$w_mean * c(2.1, 5.0, 8.4)))
  expect_equal(a$se_mu, c_mu(60L, sc) * a$sigma_hat)
  expect_named(a$w_mean, c("p5", "p50", "p95"))
  expect_s3_class(a$scenario, "reporting_scenario")
  expect_output(print(a), "the reported values \\(p5, p50, p95\\)")
  expect_output(print(sc), "3 reported values: p5, p50, p95")
  expect_true(bad(se_imputed(c(2.1, 5.0), n = 60L, scenario = sc)))            # one value short
  expect_true(bad(se_imputed(c(a = 2.1, b = 5.0, c = 8.4), n = 60L, scenario = sc)))  # other names
  expect_true(bad(se_imputed(c(5.0, 2.1, 8.4), n = 60L, scenario = sc)))       # not increasing
  expect_true(bad(se_imputed(c(2.1, 5.0, 8.4), n = 60L, scenario = sc, version = "wan_luo_shi")))
  # the range alone: the mid-range and the range over 2 E Z_(n)
  rg <- reporting_scenario(min = TRUE, max = TRUE)
  w <- estimator_weights(15L, rg, "mean"); expect_equal(unname(w), c(0.5, 0.5))
  xi <- 2 * orderStatMoments::os_moments(15L, 15L)$alpha
  expect_equal(unname(estimator_weights(15L, rg, "sd")), c(-1, 1) / xi, tolerance = 1e-10)
})

test_that("the scenario and the quantile rule are checked", {
  expect_true(bad(reporting_scenario(c(0, 0.5))))                 # 0 is the minimum: min = TRUE
  expect_true(bad(reporting_scenario(c(0.5, 1))))
  expect_true(bad(reporting_scenario(c(0.75, 0.25))))             # not increasing
  expect_true(bad(reporting_scenario(c(0.25, 0.25, 0.5))))        # repeated
  expect_true(bad(reporting_scenario(0.5)))                       # one reported value
  expect_true(bad(reporting_scenario(c(0.25, NA))))
  expect_true(bad(reporting_scenario(c(0.25, 0.75), min = NA)))
  expect_true(bad(reporting_scenario("0.5", min = TRUE)))
  sc <- reporting_scenario(c(0.05, 0.25, 0.5, 0.75, 0.95))
  expect_true(bad(c_mu(4L, sc)))                                  # fewer observations than values
  expect_true(bad(c_mu(60L, list(probs = 0.5))))                  # not a scenario
  expect_true(bad(estimator_weights(60L, sc, "mean", "luo")))     # the BLUE only
  expect_true(bad(inflation_factors(60L, sc, version = "wan_luo_shi")))
  expect_true(bad(scenario_ranks(41L, sc)))
  expect_true(bad(c_mu(25L, "S2", type = 10)))
  expect_true(bad(c_mu(25L, "S2", type = function(p, n) p)))                          # no list
  expect_true(bad(c_mu(25L, "S2", type = function(p, n) list(r = 1:2, gamma = c(0, 0)))))  # short
  expect_true(bad(c_mu(25L, "S2", type = function(p, n) list(r = c(6.5, 13, 19), gamma = rep(0, 3)))))
  expect_true(bad(c_mu(25L, "S2", type = function(p, n) list(r = c(6, 13, 19), gamma = c(0, 0, 1.2)))))
  expect_true(bad(c_mu(25L, "S2", type = function(p, n) list(r = c(0, 13, 19), gamma = rep(0, 3)))))
  expect_true(bad(c_mu(25L, "S2", type = function(p, n) list(r = c(6, 13, 25), gamma = c(0, 0, 0.5)))))
  # two quantiles on the same order statistic: the BLUE is not defined
  expect_true(bad(c_mu(25L, "S2", type = function(p, n) list(r = c(6, 6, 19), gamma = rep(0, 3)))))
  # a supplied moments object is checked against the ranks of the scenario
  expect_true(bad(c_mu(41L, sc, moments = orderStatMoments::os_moments(41L, c(3L, 11L, 21L)))))
  mo <- orderStatMoments::os_moments(41L, c(3L, 11L, 21L, 31L, 39L))
  expect_equal(c_mu(41L, sc, moments = mo), c_mu(41L, sc), tolerance = 1e-12)
})

test_that("an edited object, the boundaries of the inputs, the messages", {
  # an object edited by hand is built again, so reordered probabilities are refused and
  # changed labels are not used
  s <- reporting_scenario(c(0.05, 0.5, 0.8)); s$probs <- rev(s$probs)
  expect_error(se_imputed(c(2.1, 5, 7), 60L, s), "strictly increasing")
  s <- reporting_scenario(c(0.05, 0.5, 0.8)); s$labels <- c("x", "y", "z")
  expect_named(estimator_weights(60L, s, "mean"), c("p5", "p50", "p80"))
  expect_error(c_mu(60L, structure(list(), class = "reporting_scenario")), "probs")
  # `type` is checked also when no quantile is reported, and a character type is named
  rg <- reporting_scenario(min = TRUE, max = TRUE)
  expect_error(c_mu(15L, rg, type = 99), "1 to 9")
  expect_error(c_mu(15L, rg, type = "7"), "character")
  expect_equal(c_mu(15L, rg, type = function(p, n) stop("not called")), c_mu(15L, rg))
  # a rule: a rounding residue is taken, an integer r and a data frame are taken, a wrong
  # signature and a failing rule are named
  r0 <- function(p, n) list(r = c(7, 13, 19), gamma = rep(0, 3))
  expect_equal(c_mu(25L, "S2", type = function(p, n) list(r = c(7 + 4e-15, 13, 19), gamma = c(-1e-17, 0, 0))),
               c_mu(25L, "S2", type = r0))
  expect_equal(c_mu(25L, "S2", type = function(p, n) list(r = c(7L, 13L, 19L), gamma = rep(0, 3))),
               c_mu(25L, "S2", type = r0))
  expect_equal(c_mu(25L, "S2", type = function(p, n) data.frame(r = c(7, 13, 19), gamma = 0)),
               c_mu(25L, "S2", type = r0))
  expect_equal(c_mu(25L, "S2", type = r0), c_mu(25L, "S2"))          # the exact ranks of type 7
  expect_error(c_mu(25L, "S2", type = function(p) 1), "quantile rule given as `type` failed")
  # two reported values on one order statistic, under a built-in definition: the message
  expect_error(c_mu(10L, reporting_scenario(c(0.05, 0.5), min = TRUE), type = 1),
               "same order statistic")
  # the smallest sample size: the two values are the whole sample, so the BLUE of the mean
  # is the sample mean and its inflation factor is one
  expect_equal(unname(inflation_factors(2L, reporting_scenario(0.5, min = TRUE))["kappa_mu"]), 1,
               tolerance = 1e-10)
  expect_error(c_mu(2L, reporting_scenario(c(0.05, 0.5, 0.95))), "require n >= 3")
  # user weights of the wrong length, and the shortcut formulas
  expect_error(imputed_moments(10L, reporting_scenario(c(0.25, 0.5, 0.75)), w_mean = c(1, 0)),
               "one weight per reported value")
  expect_error(c_mu_shortcut(25L, reporting_scenario(c(0.25, 0.5, 0.75))), "S1, S2 and S3 only")
  expect_error(c_sigma_shortcut(25L, reporting_scenario(c(0.25, 0.5, 0.75))), "S1, S2 and S3 only")
})
