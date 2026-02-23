/* ============================================================
IPL PERFORMANCE ANALYSIS
FILE: 07_player_impact_analysis.sql
PURPOSE: Player Impact & Matchup Analysis
============================================================ */


-- 1. Player of the Match distribution

SELECT
player_of_match AS player,
COUNT(*) AS total_awards
FROM dbo.ipl_matches_data
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY total_awards DESC;


-- 2. Left-handed vs Right-handed batter total runs

SELECT
p.bat_style,
SUM(TRY_CAST(b.batter_runs AS INT)) AS total_runs
FROM dbo.ball_by_ball_data b
JOIN dbo.[players_data_updated] p ON b.batter = p.player_name
GROUP BY p.bat_style
ORDER BY total_runs DESC;


-- 3. Average strike rate: Left-handed vs Right-handed batters

WITH batter_stats AS (
SELECT
b.batter,
p.bat_style,
SUM(TRY_CAST(b.batter_runs AS INT)) AS total_runs,
COUNT(*) AS balls_faced
FROM dbo.ball_by_ball_data b
JOIN dbo.[players_data_updated] p ON b.batter = p.player_name
WHERE b.is_wide_ball = 0
GROUP BY b.batter, p.bat_style
)
SELECT
bat_style,
ROUND(SUM(total_runs) * 100.0 / SUM(balls_faced),2) AS strike_rate
FROM batter_stats
GROUP BY bat_style
ORDER BY strike_rate DESC;


-- 4. Performance vs bowler type (Pace vs Spin), Runs scored and wickets taken

SELECT
b.bowler_type,
SUM(TRY_CAST(b.batter_runs AS INT)) AS runs_scored,
SUM(CASE WHEN b.is_wicket = 1 AND b.player_out IS NOT NULL THEN 1 ELSE 0 END) AS wickets_lost
FROM dbo.ball_by_ball_data b
GROUP BY b.bowler_type
ORDER BY runs_scored DESC;