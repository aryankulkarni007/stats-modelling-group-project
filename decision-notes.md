# Decision notes

# 17 Nov 2026: Week 5, Choice of model for goals scored (Ozair)
1. What we found: Adding home/away (p = 0.009) and opponent rank (p = 0.004) each improved the model significantly (likelihood ratio tests). Adding an interaction between them did not (p = 0.55). AIC was lowest for the model with home/away + opponent rank (133.4).
2. What I decided: Use goals_scored ~ home_away + opponent_rank (Poisson).
3. Why: Both the LRTs and AIC point to the same model, and there is no evidence that the home advantage depends on opponent strength.

#19 Nov 2026: Week 5, Dispersion (Ozair)
1. What we found: Home goals had variance (2.93) well above the mean (1.74), but without the 8-0 match the variance fell to 1.12. The fitted model's dispersion estimate was 0.99 and the deviance goodness-of-fit test gave p = 0.22.
2. What I decided: Keep the ordinary Poisson model; quasi-Poisson not needed.
3. Why: Dispersion is close to 1, so the Poisson standard errors are reliable.

# 19 Nov 2026: Week 5, 8-0 match (Ozair)
1. What we found: One match (home 8-0 vs the rank-24 team, row 8) was the only influential observation (Cook's distance above 4/n). Refitting without it, both effects kept the same direction but became smaller: the home rate ratio fell from 2.00 (p = 0.011) to 1.71 (p = 0.061), and the rank rate ratio from 1.056 (p = 0.005) to 1.034 (p = 0.105), so neither was significant at the 5% level.
2. What I decided: Keep the match in the main model, and report the sensitivity analysis without it alongside the main results.
3. Why: It is a genuine result, not a data error, so there is no justification for deleting it. But because the evidence for both effects depends heavily on this one match, the club should treat the size of the home and opponent-rank effects with caution.
