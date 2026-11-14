# =============================================================================
# Q3. Does the match result (Win / Draw / Loss) depend on venue and opponent?
#     Part A: 2x3 contingency table, venue x result (weeks 6 & 8)
#     Part B: ordinal (proportional odds) model, result ~ venue + rank (week 9)
# Data: ashford_matches_sm2.csv
# =============================================================================

library(MASS)   # polr() for proportional odds models

matches <- read.csv("ashford_matches.csv", stringsAsFactors = TRUE)
matches$home_away <- relevel(matches$home_away, ref = "Away")
matches$result <- factor(ifelse(matches$goals_scored > matches$goals_conceded, "W",
                         ifelse(matches$goals_scored == matches$goals_conceded, "D", "L")),
                         levels = c("L", "D", "W"), ordered = TRUE)

# -----------------------------------------------------------------------------
# Part A. Contingency table
# -----------------------------------------------------------------------------
tab <- table(matches$home_away, matches$result)
tab
round(prop.table(tab, margin = 1), 2)      # result proportions by venue

# Expected counts under independence: several are < 5, so the chi-squared
# approximation is shaky -> also report Fisher's exact test
chisq.test(tab)$expected
chisq.test(tab)
fisher.test(tab)

# Same question as a log-linear (Poisson) model: independence vs saturated
counts <- as.data.frame(tab)
names(counts) <- c("venue", "result", "count")
ll_indep <- glm(count ~ venue + result, family = poisson, data = counts)
ll_sat   <- glm(count ~ venue * result, family = poisson, data = counts)
anova(ll_indep, ll_sat, test = "LRT")       # deviance = G^2 test of independence
residuals(ll_indep, type = "pearson")       # which cells drive any association?

# -----------------------------------------------------------------------------
# Part B. Ordinal model using opponent rank as well
# -----------------------------------------------------------------------------
o0 <- polr(result ~ 1,                         data = matches, Hess = TRUE)
o1 <- polr(result ~ home_away,                 data = matches, Hess = TRUE)
o2 <- polr(result ~ home_away + opponent_rank, data = matches, Hess = TRUE)
anova(o0, o1, o2)
summary(o2)

# Cumulative odds ratios (odds of a better result) with 95% CIs
round(exp(cbind(OR = coef(o2), confint(o2))), 3)

# Check proportional odds assumption: compare with two separate logistic fits
#   "at least a draw" (D/W vs L) and "win" (W vs D/L). Similar slopes = assumption OK.
fit_atleastD <- glm(I(result != "L") ~ home_away + opponent_rank, family = binomial, data = matches)
fit_win      <- glm(I(result == "W") ~ home_away + opponent_rank, family = binomial, data = matches)
round(rbind(at_least_draw = coef(fit_atleastD)[-1], win = coef(fit_win)[-1]), 3)

# Predicted probabilities of L/D/W for some scenarios
scen <- expand.grid(home_away = c("Home", "Away"), opponent_rank = c(1, 12, 24))
cbind(scen, round(predict(o2, newdata = scen, type = "probs"), 2))

# -----------------------------------------------------------------------------
# Save key figure to outputs/
# -----------------------------------------------------------------------------
dir.create("outputs", showWarnings = FALSE)
png("outputs/q3_results_by_venue.png", width = 800, height = 600, res = 120)
barplot(t(prop.table(tab, 1)), beside = TRUE, legend.text = TRUE,
        args.legend = list(x = "topleft", bty = "n"),
        ylab = "Proportion of matches", main = "Match results by venue")
dev.off()
