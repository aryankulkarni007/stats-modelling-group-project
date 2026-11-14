# =============================================================================
# Q1. Which player characteristics are associated with injury risk?
#     Response: injured (0/1)  ->  binomial (logistic) GLM, then GLMM with team
# Data: league_players_sm2.csv (620 players, 24 teams)
# =============================================================================

library(lme4)      # glmer() for the mixed model (week 10)
library(lattice)   # dotplot() of random effects (ships with R)

players <- read.csv("league_players.csv", stringsAsFactors = TRUE)
players$mins1000 <- players$minutes_played / 1000   # per 1000 minutes: nicer coefficients
str(players)

# -----------------------------------------------------------------------------
# 1. Exploratory analysis
# -----------------------------------------------------------------------------
summary(players)
mean(players$injured)                                   # overall injury rate (~18.5%)

# Injury rate by categorical variables
round(tapply(players$injured, players$position, mean), 3)
round(sort(tapply(players$injured, players$team, mean)), 2)   # big spread across teams

# Injury rate by previous injuries / training load
round(tapply(players$injured, players$prev_injuries, mean), 3)
round(tapply(players$injured, players$training_load, mean), 3)

# Numeric predictors split by injury status
par(mfrow = c(2, 3))
for (v in c("age", "minutes_played", "training_load", "prev_injuries", "bmi")) {
  boxplot(players[[v]] ~ players$injured, main = v, xlab = "injured", ylab = v)
}
par(mfrow = c(1, 1))

# Check predictors aren't strongly correlated with each other
round(cor(players[, c("age", "minutes_played", "training_load", "prev_injuries", "bmi")]), 2)

# -----------------------------------------------------------------------------
# 2. Full logistic regression and model selection
# -----------------------------------------------------------------------------
m_full <- glm(injured ~ age + mins1000 + training_load + prev_injuries + bmi + position,
              family = binomial, data = players)
summary(m_full)

# Likelihood ratio tests for dropping each term
drop1(m_full, test = "LRT")

# AIC-based backward selection (as a cross-check, not the only justification)
m_step <- step(m_full, direction = "backward", trace = 1)
formula(m_step)

# Candidate reduced model: age + training_load + prev_injuries
m_red <- glm(injured ~ age + training_load + prev_injuries,
             family = binomial, data = players)
summary(m_red)

# LRT: does the reduced model fit significantly worse than the full one?
anova(m_red, m_full, test = "LRT")

# Optional: check for non-linearity / interactions
m_quad <- update(m_red, . ~ . + I(age^2))
anova(m_red, m_quad, test = "LRT")
m_int  <- update(m_red, . ~ . + training_load:prev_injuries)
anova(m_red, m_int, test = "LRT")

# -----------------------------------------------------------------------------
# 3. Interpretation: odds ratios with 95% profile-likelihood CIs
# -----------------------------------------------------------------------------
round(exp(cbind(OR = coef(m_red), confint(m_red))), 3)

# Example predicted probabilities for an "average" player with 0 vs 3 previous injuries
newd <- data.frame(age = 25, training_load = 3, prev_injuries = c(0, 3))
predict(m_red, newdata = newd, type = "response")

# -----------------------------------------------------------------------------
# 4. Diagnostics
# -----------------------------------------------------------------------------
# Residual deviance and Pearson dispersion (binary data: deviance GOF is NOT valid,
# so use grouped checks below instead)
sum(residuals(m_red, type = "pearson")^2) / df.residual(m_red)

# Binned residual plot (raw residuals are uninformative for 0/1 data)
binned_resid <- function(model, nbins = 10) {
  p <- fitted(model)
  r <- residuals(model, type = "response")
  bins <- cut(p, quantile(p, probs = seq(0, 1, length.out = nbins + 1)), include.lowest = TRUE)
  n <- as.vector(table(bins))
  data.frame(p_mean = as.vector(tapply(p, bins, mean)),
             r_mean = as.vector(tapply(r, bins, mean)),
             n = n,
             bound = 2 * sqrt(as.vector(tapply(p * (1 - p), bins, mean)) / n))
}
br <- binned_resid(m_red)
plot(br$p_mean, br$r_mean, pch = 19, ylim = range(c(br$bound, -br$bound, br$r_mean)),
     xlab = "Mean fitted probability", ylab = "Mean residual", main = "Binned residuals")
lines(br$p_mean,  br$bound, lty = 2); lines(br$p_mean, -br$bound, lty = 2); abline(h = 0)

# Hosmer-Lemeshow-style test: observed vs expected injuries in deciles of risk
hl_test <- function(model, g = 10) {
  p <- fitted(model); y <- model$y
  grp <- cut(p, quantile(p, probs = seq(0, 1, length.out = g + 1)), include.lowest = TRUE)
  obs <- tapply(y, grp, sum); expd <- tapply(p, grp, sum); n <- tapply(y, grp, length)
  stat <- sum((obs - expd)^2 / (expd * (1 - expd / n)))
  c(statistic = stat, df = g - 2, p.value = pchisq(stat, g - 2, lower.tail = FALSE))
}
hl_test(m_red)

# Influence
plot(cooks.distance(m_red), type = "h", ylab = "Cook's distance", main = "Influence")
players[which.max(cooks.distance(m_red)), ]

# -----------------------------------------------------------------------------
# 5. Extension: do teams differ beyond player characteristics?  (GLMM, week 10)
# -----------------------------------------------------------------------------
m_glmm <- glmer(injured ~ age + training_load + prev_injuries + (1 | team),
                family = binomial, data = players)
summary(m_glmm)

# LRT for the random effect. The variance is tested on the boundary (sigma^2 = 0),
# so halve the chi-squared(1) p-value.
lrt <- as.numeric(2 * (logLik(m_glmm) - logLik(m_red)))
c(LRT = lrt, p_value = 0.5 * pchisq(lrt, df = 1, lower.tail = FALSE))

# Compare fixed effects with and without team effect
round(cbind(GLM = coef(m_red), GLMM = fixef(m_glmm)), 3)

# Predicted team effects (which teams have higher/lower risk than expected)
dotplot(ranef(m_glmm, condVar = TRUE))

# -----------------------------------------------------------------------------
# 6. Save key figures to outputs/ (keep everything, even plots not used in report)
# -----------------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)

png("outputs/q1_injury_rate_by_prev_injuries.png", width = 800, height = 600, res = 120)
barplot(tapply(players$injured, players$prev_injuries, mean),
        xlab = "Number of previous injuries", ylab = "Proportion injured",
        main = "Injury rate by previous injuries")
dev.off()

png("outputs/q1_binned_residuals.png", width = 800, height = 600, res = 120)
plot(br$p_mean, br$r_mean, pch = 19, ylim = range(c(br$bound, -br$bound, br$r_mean)),
     xlab = "Mean fitted probability", ylab = "Mean residual", main = "Binned residuals")
lines(br$p_mean,  br$bound, lty = 2); lines(br$p_mean, -br$bound, lty = 2); abline(h = 0)
dev.off()

png("outputs/q1_team_random_effects.png", width = 800, height = 900, res = 120)
print(dotplot(ranef(m_glmm, condVar = TRUE)))
dev.off()

