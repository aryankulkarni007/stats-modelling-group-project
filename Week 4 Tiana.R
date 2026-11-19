# TIANA: WEEK 4 - STATISTICAL MODELLING 2

# Load player dataset
players <- read.csv("league_players.csv")


# RESEARCH QUESTION

# Are training load, age and previous injuries
# associated with the probability of injury?

# Response variable:
# injured (0 = not injured, 1 = injured)

# Explanatory variables:
# training_load, age, prev_injuries

# Logistic regression is appropriate because
# the response variable is binary.

# FIT LOGISTIC REGRESSION MODEL


model1 <- glm(
  injured ~ training_load + age + prev_injuries,
  family = binomial(link = "logit"),
  data = players
  )


# Display model results
summary(model1)

# ODDS RATIOS AND CONFIDENCE INTERVALS

# Calculate odds ratios
exp(coef(model1))

# Approximate 95% confidence intervals
# for odds ratios (Wald intervals)
exp(confint.default(model1))

# MODEL COMPARISON

# Fit intercept-only model
model0 <- glm(
  injured ~ 1,
  family = binomial(link = "logit"),
  data = players
)

# Likelihood ratio test
anova(model0, model1, test = "Chisq")

# Compare AIC
AIC(model0, model1)

# MODEL DIAGNOSTICS

# Standardised deviance residuals
std_residuals <- rstandard(model1)

# Residuals vs fitted probabilities
plot(
  fitted(model1),
  std_residuals,
  xlab = "Fitted probability of injury",
  ylab = "Standardised deviance residuals",
  main = "Residuals vs Fitted Values",
  pch = 16,
  col = "steelblue"
)

# Add reference line
abline(h = 0, col = "red", lty = 2)

# Count large residuals
sum(abs(std_residuals) > 2)

# Cook's distance plot
plot(
  cooks.distance(model1),
  type = "h",
  main = "Cook's Distance",
  xlab = "Player observation",
  ylab = "Cook's distance"
)

# FIT INTERACTION MODEL
# Investigate whether the association between
# training load and injury depends on age.

model2 <- glm(
  injured ~ training_load * age + prev_injuries,
  family = binomial(link = "logit"),
  data = players
)

# Display interaction model results
summary(model2)

# COMPARE INTERACTION MODEL

# Likelihood ratio test
anova(model1, model2, test = "Chisq")

# Compare AIC
AIC(model1, model2)

# INTERPRET INTERACTION

# Calculate training-load odds ratios
# at ages 20, 25 and 30.

ages <- c(20, 25, 30)

training_OR <- exp(
  coef(model2)["training_load"] +
    coef(model2)["training_load:age"] * ages
)

# Display odds ratios by age
data.frame(
  Age = ages,
  Training_Load_Odds_Ratio = training_OR
)

# FINAL FINDINGS


# Model 1:
# Training load, age and previous injuries
# are all positively associated with injury.

# Model 1 odds ratios:
# Training load: 1.377
# Age: 1.111
# Previous injuries: 1.667

# Model comparison:
# Model 1 improves on the intercept-only model.
# LRT p-value = 5.521e-12

# Diagnostics:
# 26 observations have absolute standardised
# deviance residuals greater than 2.
# Binary residual plots have limited use
# for assessing overall goodness of fit.

# Interaction model:
# The training_load:age interaction is
# statistically significant.
# LRT p-value = 0.0001855

# AIC:
# Model 1 = 547.27
# Model 2 = 535.30

# Model 2 is preferred over Model 1 based
# on this comparison.

# Conclusion:
# The association between training load
# and injury varies with player age.
# Previous injuries are also associated
# with injury risk.

# These are associations, not evidence
# of causation.

# Further model checking is needed before
# claiming that Model 2 fits adequately.

