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

#20 Nov 2026: Week 5, Goals conceded and Underdispersion (Ozair)
1. What we found: The same model as for goals scored was selected (home/away + opponent rank). Ashford conceded about half as many goals at home (rate ratio 0.52, 95% CI 0.26 to 1.00) and about 5% fewer per place lower the opponent ranked (0.949, 0.905 to 0.994). The dispersion was 0.57, so goals conceded were underdispersed.
2. What I decided: Report the standard Poisson model rather than the quasi-Poisson.
3. Why: Because the dispersion is below 1, the quasi-Poisson adjustment would shrink the standard errors and make the effects look more certain (home p = 0.015 instead of 0.056). We cannot be sure this adjustment is accurate with only 46 matches, so the more cautious Poisson model avoids giving the club misleading information.

# 20 Nov 2026: Week 5, Negative binomial and offset (Ozair)
1. What we found: A negative binomial model for goals scored gave almost identical coefficients to the Poisson (home 0.691 vs 0.693; rank 0.0536 vs 0.0543). Theta was estimated at 34 with a standard error of 144, so the data cannot distinguish it from the Poisson (theta → infinity). AIC was higher for the negative binomial (135.4 vs 133.4).
2. What I decided: Keep the Poisson model, and do not use an offset.
3. Why: The negative binomial adds an extra parameter but does not improve the fit, which agrees with the dispersion estimate of 0.99 (no overdispersion). No offset is needed because every observation is a single match of the same length, so exposure is equal for all matches.
