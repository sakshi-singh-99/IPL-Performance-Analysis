/* =========================================================
08_final_insights.sql
FINAL INSIGHTS & CONCLUSIONS
Simple queries only (same style as before)
========================================================= */


----------------------------------------------------------
-- 1) DOES TOSS HELP WIN MATCH?
----------------------------------------------------------
SELECT
    CASE 
        WHEN toss_winner = match_winner THEN 'Toss Winner Won'
        ELSE 'Toss Winner Lost'
    END AS toss_result,
    COUNT(*) AS total_matches
FROM dbo.ipl_matches_data
GROUP BY CASE 
        WHEN toss_winner = match_winner THEN 'Toss Winner Won'
        ELSE 'Toss Winner Lost'
    END;



----------------------------------------------------------
-- 2) CHASING vs DEFENDING SUCCESS
----------------------------------------------------------
SELECT
CASE
    WHEN TRY_CAST(win_by_runs AS INT) > 0 THEN 'Defending Team Won'
    WHEN TRY_CAST(win_by_wickets AS INT) > 0 THEN 'Chasing Team Won'
    ELSE 'No Result'
END AS match_result,
COUNT(*) AS matches
FROM dbo.ipl_matches_data
GROUP BY
CASE
    WHEN TRY_CAST(win_by_runs AS INT) > 0 THEN 'Defending Team Won'
    WHEN TRY_CAST(win_by_wickets AS INT) > 0 THEN 'Chasing Team Won'
    ELSE 'No Result'
END;



----------------------------------------------------------
-- 3) HIGH SCORING MATCHES WIN MORE?
-- (average runs scored by winning teams)
----------------------------------------------------------
SELECT
    m.match_winner,
    ROUND(AVG(CAST(b.total_runs AS FLOAT)),2) AS avg_runs_scored
FROM dbo.ball_by_ball_data b
JOIN dbo.ipl_matches_data m
ON b.match_id = m.match_id
WHERE b.team_batting = m.match_winner
GROUP BY m.match_winner
ORDER BY avg_runs_scored DESC;



----------------------------------------------------------
-- 4) DEATH OVER BOWLING ECONOMY (16-20 overs)
----------------------------------------------------------
SELECT TOP 15
    bowler,
    ROUND(SUM(CAST(total_runs AS FLOAT)) * 6 / COUNT(*),2) AS economy
FROM dbo.ball_by_ball_data
WHERE over_number >= 16
GROUP BY bowler
ORDER BY economy ASC;



----------------------------------------------------------
-- 5) WHICH BATTER TYPE SCORES MORE?
----------------------------------------------------------
SELECT
    batsman_type,
    SUM(CAST(batter_runs AS INT)) AS total_runs,
    ROUND(SUM(CAST(batter_runs AS FLOAT)) * 100 / COUNT(*),2) AS strike_rate
FROM dbo.ball_by_ball_data
GROUP BY batsman_type;



----------------------------------------------------------
-- 6) PACE vs SPIN EFFECTIVENESS
----------------------------------------------------------
SELECT
    bowler_type,
    SUM(CAST(batter_runs AS INT)) AS runs_given,
    ROUND(SUM(CAST(batter_runs AS FLOAT)) * 6 / COUNT(*),2) AS economy
FROM dbo.ball_by_ball_data
GROUP BY bowler_type;