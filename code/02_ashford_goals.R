# =============================================================================
# Q2. How do venue (home/away) and opponent strength affect Ashford's goals
#     scored and conceded?
#     Response: counts  ->  Poisson GLM (week 5), check dispersion + influence
# Data: ashford_matches_sm2.csv (46 matches)
# NOTE: check in the Data Brief whether opponent_rank 1 = strongest team.
#       Rank 9 never appears, which suggests it is Ashford's own position.
# =============================================================================

matches <- read.csv("ashford_matches.csv", stringsAsFactors = TRUE)
matches$home_away <- relevel(matches$home_away, ref = "Away")
str(matches)

# -----------------------------------------------------------------------------
# 1. Exploratory analysis
# -----------------------------------------------------------------------------
# Mean vs variance by venue: Poisson assumes these are roughly equal
aggregate(cbind(goals_scored, goals_conceded) ~ home_away, data = matches,
          FUN = function(x) c(mean = mean(x), var = var(x)))

table(matches$goals_scored)
table(matches$goals_conceded)

par(mfrow = c(1, 2))
plot(jitter(goals_scored, 0.3) ~ opponent_rank, data = matches,
     col = ifelse(home_away == "Home", "blue", "red"), pch = 19,
     xlab = "Opponent rank", ylab = "Goals scored", main = "Goals scored")
legend("topleft", c("Home", "Away"), col = c("blue", "red"), pch = 19, bty = "n")
plot(jitter(goals_conceded, 0.3) ~ opponent_rank, data = matches,
     col = ifelse(home_away == "Home", "blue", "red"), pch = 19,
     xlab = "Opponent rank", ylab = "Goals conceded", main = "Goals conceded")
par(mfrow = c(1, 1))
# The 8-0 home win against rank 24 stands out -- keep an eye on it.

# -----------------------------------------------------------------------------
# 2. Goals scored: nested Poisson models + LRTs
# -----------------------------------------------------------------------------
s0 <- glm(goals_scored ~ 1,                         family = poisson, data = matches)
s1 <- glm(goals_scored ~ home_away,                 family = poisson, data = matches)
s2 <- glm(goals_scored ~ home_away + opponent_rank, family = poisson, data = matches)
s3 <- glm(goals_scored ~ home_away * opponent_rank, family = poisson, data = matches)
anova(s0, s1, s2, s3, test = "LRT")
AIC(s0, s1, s2, s3)
summary(s2)

# Rate ratios with 95% CIs
round(exp(cbind(RR = coef(s2), confint(s2))), 3)

# Fit diagnostics
c(deviance = deviance(s2), df = df.residual(s2),
  p_GOF = pchisq(deviance(s2), df.residual(s2), lower.tail = FALSE))
sum(residuals(s2, type = "pearson")^2) / df.residual(s2)      # dispersion estimate

par(mfrow = c(2, 2)); plot(s2); par(mfrow = c(1, 1))           # standard residual plots

# Influence: Cook's distance and leverage
cd <- cooks.distance(s2)
plot(cd, type = "h", ylab = "Cook's distance", main = "Goals scored: influence")
abline(h = 4 / nrow(matches), lty = 2)
matches[cd > 4 / nrow(matches), ]

# Sensitivity: refit without the 8-0 match. If conclusions change, report this!
s2_no8 <- update(s2, data = subset(matches, goals_scored < 8))
round(cbind(all = coef(s2), without_8_0 = coef(s2_no8)), 3)
summary(s2_no8)

# Robustness: quasi-Poisson (adjusts SEs for over/under-dispersion)
summary(glm(goals_scored ~ home_away + opponent_rank, family = quasipoisson, data = matches))

# -----------------------------------------------------------------------------
# 3. Goals conceded: same steps
# -----------------------------------------------------------------------------
c0 <- glm(goals_conceded ~ 1,                         family = poisson, data = matches)
c1 <- glm(goals_conceded ~ home_away,                 family = poisson, data = matches)
c2 <- glm(goals_conceded ~ home_away + opponent_rank, family = poisson, data = matches)
c3 <- glm(goals_conceded ~ home_away * opponent_rank, family = poisson, data = matches)
anova(c0, c1, c2, c3, test = "LRT")
summary(c2)
round(exp(cbind(RR = coef(c2), confint(c2))), 3)

# Dispersion: early checks suggest UNDER-dispersion (~0.6) -- discuss what this means
sum(residuals(c2, type = "pearson")^2) / df.residual(c2)
summary(glm(goals_conceded ~ home_away + opponent_rank, family = quasipoisson, data = matches))
par(mfrow = c(2, 2)); plot(c2); par(mfrow = c(1, 1))

# -----------------------------------------------------------------------------
# 4. Interpretation: expected goals for some scenarios
# -----------------------------------------------------------------------------
scen <- expand.grid(home_away = c("Home", "Away"), opponent_rank = c(1, 12, 24))
scen$exp_scored   <- predict(s2, newdata = scen, type = "response")
scen$exp_conceded <- predict(c2, newdata = scen, type = "response")
scen

# -----------------------------------------------------------------------------
# 5. Save key figures to outputs/
# -----------------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)

png("outputs/q2_goals_vs_rank.png", width = 1200, height = 550, res = 120)
par(mfrow = c(1, 2))
for (v in c("goals_scored", "goals_conceded")) {
  plot(jitter(matches[[v]], 0.3) ~ matches$opponent_rank, pch = 19,
       col = ifelse(matches$home_away == "Home", "blue", "red"),
       xlab = "Opponent rank", ylab = v, main = v)
  r <- 1:24
  lines(r, predict(if (v == "goals_scored") s2 else c2,
                   newdata = data.frame(home_away = "Home", opponent_rank = r),
                   type = "response"), col = "blue")
  lines(r, predict(if (v == "goals_scored") s2 else c2,
                   newdata = data.frame(home_away = "Away", opponent_rank = r),
                   type = "response"), col = "red")
}
legend("topleft", c("Home", "Away"), col = c("blue", "red"), lty = 1, pch = 19, bty = "n")
par(mfrow = c(1, 1))
dev.off()

png("outputs/q2_goals_scored_cooks.png", width = 800, height = 600, res = 120)
plot(cd, type = "h", ylab = "Cook's distance", main = "Goals scored: influence")
abline(h = 4 / nrow(matches), lty = 2)
dev.off()
