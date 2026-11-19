
# TIANA: WEEK 5 - STATISTICAL MODELLING 2
# 1. Load dataset
players <- read.csv("league_players.csv")

# 2. Fit preferred logistic regression model
model2 <- glm(
  injured ~ training_load * age + prev_injuries,
  family = binomial(link = "logit"),
  data = players
)

# 3. Display model summary
summary(model2)

# 4. Calculate standardised deviance residuals
std_res <- rstandard(model2)

# 5. Plot residuals against fitted probabilities
plot(
  fitted(model2),
  std_res,
  xlab = "Fitted probability of injury",
  ylab = "Standardised deviance residuals",
  main = "Week 5: Residuals vs Fitted",
  pch = 16,
  col = "steelblue"
)

abline(h = 0, col = "red", lty = 2)

# 6. Count large residuals
sum(abs(std_res) > 2)

# 7. Check Cook's distance
plot(
  cooks.distance(model2),
  type = "h",
  main = "Week 5: Cook's Distance",
  xlab = "Player observation",
  ylab = "Cook's distance"
)

# 8. Find maximum Cook's distance
max(cooks.distance(model2))

# Influence Investigation

# Identify the most influential observation
most_influential <- which.max(
  cooks.distance(model2)
)

# Display observation number
most_influential

# View the player's data
players[most_influential, ]

# Refit model without this observation
model2_check <- glm(
  injured ~ training_load * age + prev_injuries,
  family = binomial(link = "logit"),
  data = players[-most_influential, ]
)

# Compare coefficients before and after removal
data.frame(
  Original = coef(model2),
  Without_Observation = coef(model2_check)
)
