/* ============================================================
IPL PERFORMANCE ANALYSIS
FILE: 05_team_analysis.sql
PURPOSE: Beginner-friendly Team Performance Analysis
============================================================ */


-- 1. Total wins by each team

SELECT
match_winner AS team,
COUNT(*) AS total_wins
FROM dbo.ipl_matches_data
WHERE match_winner IS NOT NULL
GROUP BY match_winner
ORDER BY total_wins DESC;


-- 2. Total matches played by each team

SELECT
team_name,
COUNT(*) AS total_matches
FROM (
SELECT team1 AS team_name FROM dbo.ipl_matches_data
UNION ALL
SELECT team2 AS team_name FROM dbo.ipl_matches_data
) AS all_teams
GROUP BY team_name
ORDER BY total_matches DESC;


-- 3. Win percentage by team

-- Step 1: Total wins
SELECT
m.team_name,
w.total_wins,
m.total_matches,
ROUND((CAST(w.total_wins AS FLOAT) / m.total_matches) * 100,2) AS win_percentage
FROM
(
-- Total matches per team
SELECT
team_name,
COUNT(*) AS total_matches
FROM (
SELECT team1 AS team_name FROM dbo.ipl_matches_data
UNION ALL
SELECT team2 AS team_name FROM dbo.ipl_matches_data
) AS all_teams
GROUP BY team_name
) m
LEFT JOIN
(
-- Total wins per team
SELECT
match_winner AS team_name,
COUNT(*) AS total_wins
FROM dbo.ipl_matches_data
WHERE match_winner IS NOT NULL
GROUP BY match_winner
) w
ON m.team_name = w.team_name
ORDER BY win_percentage DESC;


-- 4. Chasing wins (won by wickets)

SELECT
match_winner AS team,
COUNT(*) AS chasing_wins
FROM dbo.ipl_matches_data
WHERE TRY_CAST(win_by_wickets AS INT) > 0
GROUP BY match_winner
ORDER BY chasing_wins DESC;


-- 5. Defending wins (won by runs)

SELECT
match_winner AS team,
COUNT(*) AS defending_wins
FROM dbo.ipl_matches_data
WHERE TRY_CAST(win_by_runs AS INT) > 0
GROUP BY match_winner
ORDER BY defending_wins DESC;


-- 6. Home ground wins (team wins at their venue)

SELECT
match_winner AS team,
venue,
COUNT(*) AS wins_at_venue
FROM dbo.ipl_matches_data
WHERE match_winner IS NOT NULL
GROUP BY match_winner, venue
ORDER BY wins_at_venue DESC;