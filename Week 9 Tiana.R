# TIANA: WEEK 9 - STATISTICAL MODELLING 2

# 1. Load match dataset
matches <- read.csv("ashford_matches.csv")

# 2. Examine dataset
str(matches)
head(matches)
summary(matches)

# 3. Classify match results
matches$result <- ifelse(
  matches$goals_scored > matches$goals_conceded,
  "Win",
  ifelse(
    matches$goals_scored < matches$goals_conceded,
    "Loss",
    "Draw"
  )
)

# 4. Count wins, losses and draws
table(matches$result)

# 5. Examine home and away results
table(matches$home_away, matches$result)

# 6. Examine opponent rankings
summary(matches$opponent_rank)
