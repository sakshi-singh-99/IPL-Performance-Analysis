/* ============================================================
IPL PERFORMANCE ANALYSIS
FILE: 04_bowling_analysis.sql
PURPOSE: Bowling Performance Analysis
============================================================ */

-- 1. Total wickets taken by each bowler

SELECT
bowler,
COUNT(*) AS total_wickets
FROM dbo.ball_by_ball_data
WHERE is_wicket = 1
GROUP BY bowler
ORDER BY total_wickets DESC;


-- 2. Economy rate of each bowler: Economy = Runs conceded per over

WITH bowler_runs AS (
SELECT
bowler,
SUM(TRY_CAST(total_runs AS INT)) AS runs_conceded,
COUNT(*) AS balls_bowled
FROM dbo.ball_by_ball_data
WHERE is_wide_ball = 0 AND is_no_ball = 0
GROUP BY bowler
)
SELECT
bowler,
runs_conceded,
balls_bowled,
ROUND(runs_conceded / (balls_bowled / 6.0),2) AS economy_rate
FROM bowler_runs
ORDER BY economy_rate ASC;


-- 3. Total dot balls bowled by each bowler

SELECT
bowler,
SUM(CASE WHEN TRY_CAST(total_runs AS INT) = 0 AND is_wide_ball = 0 AND is_no_ball = 0 THEN 1 ELSE 0 END) AS dot_balls
FROM dbo.ball_by_ball_data
GROUP BY bowler
ORDER BY dot_balls DESC;


-- 4. Top wicket-takers season-wise

WITH bowler_season AS (
SELECT
m.season_id,
b.bowler,
COUNT(*) AS total_wickets
FROM dbo.ball_by_ball_data b
JOIN dbo.ipl_matches_data m ON b.match_id = m.match_id
WHERE b.is_wicket = 1
GROUP BY m.season_id, b.bowler
)
SELECT season_id, bowler, total_wickets
FROM (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY season_id ORDER BY total_wickets DESC) AS rn
FROM bowler_season
) t
WHERE rn <= 10
ORDER BY season_id, total_wickets DESC;


-- 5. Death over (16–20) bowling performance: Wickets & Economy in death overs

WITH death_bowling AS (
SELECT
bowler,
SUM(TRY_CAST(total_runs AS INT)) AS runs_conceded,
COUNT(*) AS balls_bowled,
SUM(CASE WHEN is_wicket = 1 THEN 1 ELSE 0 END) AS wickets_in_death
FROM dbo.ball_by_ball_data
WHERE over_number BETWEEN 16 AND 20
GROUP BY bowler
)
SELECT
bowler,
wickets_in_death,
balls_bowled,
ROUND(runs_conceded / (balls_bowled / 6.0),2) AS death_economy
FROM death_bowling
ORDER BY wickets_in_death DESC, death_economy ASC;


-- 6. Performance vs batter type (Pace vs Spin)

SELECT
bowler,
bowler_type,
SUM(TRY_CAST(total_runs AS INT)) AS runs_conceded,
COUNT(*) AS balls_bowled,
SUM(CASE WHEN is_wicket = 1 THEN 1 ELSE 0 END) AS wickets_taken,
ROUND(SUM(TRY_CAST(total_runs AS INT)) / (COUNT(*) / 6.0),2) AS economy_rate
FROM dbo.ball_by_ball_data
GROUP BY bowler, bowler_type
ORDER BY wickets_taken DESC, economy_rate ASC;