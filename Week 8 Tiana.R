# TIANA: WEEK 8 - STATISTICAL MODELLING 2

# Load the dataset
players <- read.csv("league_players.csv")

# Create training-load groups
players$training_group <- ifelse(
  players$training_load <= 3,
  "Low",
  "High"
)

# Convert variables into factors
players$position <- factor(players$position)

players$injured <- factor(
  players$injured,
  levels = c(0, 1),
  labels = c("No", "Yes")
)

players$training_group <- factor(
  players$training_group,
  levels = c("Low", "High")
)

# Create 3 way contingency table
three_way_table <- table(
  players$position,
  players$injured,
  players$training_group
)

# Display the table
three_way_table

# Injury percentages within each
# position and training-load group
round(
  prop.table(
    three_way_table,
    margin = c(1, 3)
  ) * 100,
  2
)
