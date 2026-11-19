# TIANA: WEEK 6 - STATISTICAL MODELLING 2

# Contingency Tables

# Load player dataset
players <- read.csv("league_players.csv")

# Create a contingency table
# Position vs injury status
injury_table <- table(
  players$position,
  players$injured
)

# Display the table
injury_table

# Calculate row percentages
# Percentage injured/not injured
# within each playing position
round(
  prop.table(injury_table, margin = 1) * 100,
  2
)

# Chi-squared test
chi_result <- chisq.test(injury_table)

# Display test results
chi_result

# 6. Check expected cell counts
chi_result$expected

# Loglinear Models

# Convert contingency table into a data frame
injury_counts <- as.data.frame(injury_table)

# Give the columns clear names
names(injury_counts) <- c(
  "position", "injured", "frequency"
)

# Fit independence model
log_model0 <- glm(
  frequency ~ position + injured,
  family = poisson(link = "log"),
  data = injury_counts
)

# Fit association model
log_model1 <- glm(
  frequency ~ position * injured,
  family = poisson(link = "log"),
  data = injury_counts
)

# View independence model
summary(log_model0)

# Compare models using likelihood ratio test
anova(log_model0, log_model1, test = "Chisq")

# Compare AIC values
AIC(log_model0, log_model1)
