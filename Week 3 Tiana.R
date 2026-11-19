# TIANA: WEEK 3 - STATISTICAL MODELLING 2

# Load the datasets
players <- read.csv("league_players.csv")
matches <- read.csv("ashford_matches.csv")

# Examine variable types
str(players)
str(matches)

# Examine possible response variables
table(players$injured)
summary(players$minutes_played)

summary(matches$goals_scored)
summary(matches$goals_conceded)

# Examine possible explanatory variables
summary(players$age)
summary(players$training_load)
summary(players$prev_injuries)

table(players$position)
table(matches$home_away)
summary(matches$opponent_rank)

# Research question:
# Are player characteristics associated with
# the probability of injury?

# Response variable:
# injured (binary: 0 = no, 1 = yes)

# Potential explanatory variables:
# age, training_load, prev_injuries,
# position and BMI

# Proposed model:
# Binomial GLM with logit link
# (logistic regression)

# Reason:
# The response is binary, so ordinary linear regression is not appropriate for modelling injury probabilities.

# Other possible analysiis:
# goals_scored: count response, Poisson GLM
# goals_conceded: count response, Poisson GLM
# minutes_played: numerical response,
# potentially a normal linear model

# Injury rates by training load
table(players$training_load, players$injured)

# Proportion injured at each training load
prop.table(
  table(players$training_load, players$injured),
  margin = 1
)

# Injury rates vary across training loads.
#
# Training load 1: 15.0%
# Training load 2: 11.3%
# Training load 3: 15.9%
# Training load 4: 25.9%
# Training load 5: 25.7%
#
# Players with training loads of 4 and 5
# have higher observed injury proportions. This suggests a possible association
# between training load and injury. A logistic regression model could assess
# this relationship while accounting for other explanatory variables.
#These descriptive results do not establish a causal relationship.

