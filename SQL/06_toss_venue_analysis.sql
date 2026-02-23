/* ============================================================
IPL PERFORMANCE ANALYSIS
FILE: 06_toss_venue_analysis.sql
PURPOSE: Toss and Venue Impact Analysis
============================================================ */


-- 1. Toss winner vs match winner correlation

SELECT
toss_winner,
match_winner,
COUNT(*) AS total_matches
FROM dbo.ipl_matches_data
WHERE toss_winner IS NOT NULL AND match_winner IS NOT NULL
GROUP BY toss_winner, match_winner
ORDER BY toss_winner, total_matches DESC;


-- 2. How often toss winner wins the match (percentage)

SELECT
ROUND(
COUNT(CASE WHEN toss_winner = match_winner THEN 1 END) * 100.0
/ COUNT(*)
,2) AS toss_win_percentage
FROM dbo.ipl_matches_data
WHERE toss_winner IS NOT NULL AND match_winner IS NOT NULL;


-- 3. Toss decision impact (bat or field) on match result

SELECT
toss_decision,
COUNT(*) AS total_matches,
COUNT(CASE WHEN toss_winner = match_winner THEN 1 END) AS toss_winner_matches,
ROUND(CAST(COUNT(CASE WHEN toss_winner = match_winner THEN 1 END) AS FLOAT) / COUNT(*) * 100,2) AS toss_win_percentage
FROM dbo.ipl_matches_data
WHERE toss_winner IS NOT NULL AND toss_decision IS NOT NULL
GROUP BY toss_decision
ORDER BY toss_win_percentage DESC;


-- 4. Highest average scores by venue: Average first innings total per venue

WITH first_innings AS (
SELECT
m.venue,
b.match_id,
SUM(TRY_CAST(b.total_runs AS INT)) AS first_innings_runs
FROM dbo.ball_by_ball_data b
JOIN dbo.ipl_matches_data m ON b.match_id = m.match_id
WHERE b.innings = 1
GROUP BY m.venue, b.match_id
)
SELECT
venue,
ROUND(AVG(first_innings_runs),2) AS avg_first_innings_score
FROM first_innings
GROUP BY venue
ORDER BY avg_first_innings_score DESC;