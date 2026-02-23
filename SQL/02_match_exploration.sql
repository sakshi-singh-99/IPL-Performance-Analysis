/* ============================================================
IPL PERFORMANCE ANALYSIS
FILE: 02_match_exploration.sql
PURPOSE: Understand season trends and match scoring patterns
============================================================ */

-- 1. Matches played per season

SELECT
season_id,
COUNT(DISTINCT match_id) AS total_matches
FROM dbo.ipl_matches_data
GROUP BY season_id
ORDER BY season_id;


-- 2. First innings total per match (Used later for multiple analyses)

WITH first_innings_score AS (
SELECT
match_id,
season_id,
SUM(total_runs) AS first_innings_runs
FROM dbo.ball_by_ball_data
WHERE innings = 1
GROUP BY match_id, season_id
)
SELECT * FROM first_innings_score
ORDER BY season_id, match_id;


-- 3. Average first innings score season-wise

WITH first_innings_score AS (
SELECT
match_id,
season_id,
SUM(total_runs) AS first_innings_runs
FROM dbo.ball_by_ball_data
WHERE innings = 1
GROUP BY match_id, season_id
)
SELECT
season_id,
ROUND(AVG(first_innings_runs),2) AS avg_first_innings_score
FROM first_innings_score
GROUP BY season_id
ORDER BY season_id;


-- 4. Highest team totals ever recorded

WITH innings_totals AS (
SELECT
match_id,
season_id,
innings,
SUM(total_runs) AS innings_total
FROM dbo.ball_by_ball_data
GROUP BY match_id, season_id, innings
)
SELECT TOP 20
season_id,
match_id,
innings,
innings_total
FROM innings_totals
ORDER BY innings_total DESC;


-- 5. Winning margin distribution (runs vs wickets)

SELECT
    CASE
        WHEN TRY_CAST(win_by_runs AS INT) > 0 THEN 'Defending Team Won (Runs)'
        WHEN TRY_CAST(win_by_wickets AS INT) > 0 THEN 'Chasing Team Won (Wickets)'
        ELSE 'No Result'
    END AS match_result_type,
    COUNT(*) AS total_matches
FROM dbo.ipl_matches_data
GROUP BY
    CASE
        WHEN TRY_CAST(win_by_runs AS INT) > 0 THEN 'Defending Team Won (Runs)'
        WHEN TRY_CAST(win_by_wickets AS INT) > 0 THEN 'Chasing Team Won (Wickets)'
        ELSE 'No Result'
    END;







-- 6. Average winning margin (runs)

SELECT
    ROUND(AVG(TRY_CAST(win_by_runs AS FLOAT)),2) AS avg_win_by_runs
FROM dbo.ipl_matches_data
WHERE TRY_CAST(win_by_runs AS INT) > 0;

SELECT
    ROUND(AVG(TRY_CAST(win_by_wickets AS FLOAT)),2) AS avg_win_by_wickets
FROM dbo.ipl_matches_data
WHERE TRY_CAST(win_by_wickets AS INT) > 0;


-- 7. Average winning margin (wickets)

SELECT
    ROUND(AVG(TRY_CAST(win_by_wickets AS FLOAT)),2) AS avg_win_by_wickets
FROM dbo.ipl_matches_data
WHERE TRY_CAST(win_by_wickets AS INT) > 0;


-- 8. Frequency of Super Overs

SELECT
    COUNT(DISTINCT match_id) AS total_super_over_matches
FROM dbo.ball_by_ball_data
WHERE TRY_CAST(is_super_over AS INT) = 1;


-- 9. Percentage of matches with Super Over

SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN TRY_CAST(is_super_over AS INT) = 1 THEN match_id END) * 100.0
        / COUNT(DISTINCT match_id)
    ,2) AS super_over_percentage
FROM dbo.ball_by_ball_data;