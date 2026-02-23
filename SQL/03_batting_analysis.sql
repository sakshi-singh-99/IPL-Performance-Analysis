/* ============================================================
IPL PERFORMANCE ANALYSIS
FILE: 03_batting_analysis.sql
PURPOSE: Simple Batting Performance Analysis
============================================================ */


-- 1. Total runs scored by each batter

SELECT
batter,
SUM(TRY_CAST(batter_runs AS INT)) AS total_runs
FROM dbo.ball_by_ball_data
GROUP BY batter
ORDER BY total_runs DESC;


-- 2. Strike rate of each batter: Strike Rate = (Total Runs / Balls Faced) * 100

SELECT
batter,
SUM(TRY_CAST(batter_runs AS INT)) AS total_runs,
COUNT(*) AS balls_faced,
ROUND(SUM(TRY_CAST(batter_runs AS INT)) * 100.0 / COUNT(*),2) AS strike_rate
FROM dbo.ball_by_ball_data
WHERE is_wide_ball = 0
GROUP BY batter
ORDER BY strike_rate DESC;

-- 3. Count of 4s and 6s by each batter

SELECT
batter,
SUM(CASE WHEN TRY_CAST(batter_runs AS INT) = 4 THEN 1 ELSE 0 END) AS total_4s,
SUM(CASE WHEN TRY_CAST(batter_runs AS INT) = 6 THEN 1 ELSE 0 END) AS total_6s
FROM dbo.ball_by_ball_data
GROUP BY batter
ORDER BY total_6s DESC, total_4s DESC;


-- 4. Top 10 run scorers season-wise

WITH batter_season AS (
SELECT
m.season_id,
b.batter,
SUM(TRY_CAST(b.batter_runs AS INT)) AS total_runs
FROM dbo.ball_by_ball_data b
JOIN dbo.ipl_matches_data m ON b.match_id = m.match_id
GROUP BY m.season_id, b.batter
)
SELECT season_id, batter, total_runs
FROM (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY season_id ORDER BY total_runs DESC) AS rn
FROM batter_season
) t
WHERE rn <= 10
ORDER BY season_id, total_runs DESC;


-- 5. Phase-wise batting performance: Powerplay (1–6), Middle overs (7–15), Death overs (16–20)

SELECT
batter,
SUM(CASE WHEN over_number BETWEEN 1 AND 6 THEN TRY_CAST(batter_runs AS INT) ELSE 0 END) AS powerplay_runs,
SUM(CASE WHEN over_number BETWEEN 7 AND 15 THEN TRY_CAST(batter_runs AS INT) ELSE 0 END) AS middle_runs,
SUM(CASE WHEN over_number BETWEEN 16 AND 20 THEN TRY_CAST(batter_runs AS INT) ELSE 0 END) AS death_runs
FROM dbo.ball_by_ball_data
GROUP BY batter
ORDER BY powerplay_runs DESC, death_runs DESC;