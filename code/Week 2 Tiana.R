# TIANA: WEEK 2 - STATISTICAL MODELLING 2

# loading datasets
players <- read.csv("league_players.csv")
matches <- read.csv("ashford_matches.csv")

# view first 6 rows
head(players)
head(matches)

# checking dimensions of dataset
dim(players) 
dim(matches)

# summary(players)
summary(matches)
mean(players$age)
sd(players$age)

mean(players$minutes_played)
sd(players$minutes_played)

# graphs for visuals stuff
hist(players$age,
     main = "Distribution of Player Ages",
     xlab = "Age")

boxplot(age ~ position,
        data = players,
        main = "Age by Position")

plot(players$age,
     players$minutes_played,
     main = "Age vs Minutes Played",
     xlab = "Age",
     ylab = "Minutes Played")
# linear regression
model <- lm(minutes_played ~ age,
            data = players)

summary(model)