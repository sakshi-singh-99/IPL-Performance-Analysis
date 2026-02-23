/* ============================================================
IPL PERFORMANCE ANALYSIS
FILE: 01_database_check.sql
PURPOSE: Validate imported IPL datasets before analysis
============================================================ */

-- 1. Preview all tables

SELECT TOP 10 * FROM ball_by_ball_data;
SELECT TOP 10 * FROM ipl_matches_data;
SELECT TOP 10 * FROM players_data_updated;
SELECT TOP 10 * FROM teams_data;


-- 2. Count rows in each table

SELECT 'ball_by_ball_data' AS table_name, COUNT(*) AS total_rows FROM ball_by_ball_data
UNION ALL
SELECT 'ipl_matches_data', COUNT(*) FROM ipl_matches_data
UNION ALL
SELECT 'players_data_updated', COUNT(*) FROM players_data_updated
UNION ALL
SELECT 'teams_data', COUNT(*) FROM teams_data;


-- 3. Check seasons available

SELECT DISTINCT season_id
FROM ipl_matches_data
ORDER BY season_id;


-- 4. Matches per season

SELECT season_id, COUNT(DISTINCT match_id) AS total_matches
FROM ipl_matches_data
GROUP BY season_id
ORDER BY season_id;


-- 5. Ball data matches match table (Every match in ball_by_ball should exist in matches table)

SELECT COUNT(DISTINCT b.match_id) AS matches_in_ball_data,
COUNT(DISTINCT m.match_id) AS matches_in_match_table
FROM ball_by_ball_data b
FULL JOIN ipl_matches_data m
ON b.match_id = m.match_id;


-- 6. Check invalid overs (should be 1–20 normally)

SELECT DISTINCT over_number
FROM ball_by_ball_data
ORDER BY over_number;


-- 7. Check invalid balls per over (>10 means bad data)

SELECT over_number, ball_number, COUNT(*) AS occurrences
FROM ball_by_ball_data
GROUP BY over_number, ball_number
HAVING ball_number > 10
ORDER BY ball_number DESC;


-- 8. Check innings values (should be 1 or 2, sometimes 3 for super over)

SELECT DISTINCT innings
FROM ball_by_ball_data
ORDER BY innings;


-- 9. Check negative or impossible runs

SELECT *
FROM ball_by_ball_data
WHERE total_runs < 0
OR batter_runs < 0
OR extras < 0;


-- 10. Check duplicate ball entries (One ball = unique(match, innings, over, ball))

SELECT match_id, innings, over_number, ball_number, COUNT(*) AS duplicate_count
FROM ball_by_ball_data
GROUP BY match_id, innings, over_number, ball_number
HAVING COUNT(*) > 1;


-- 11. Check missing teams in matches table

SELECT *
FROM ipl_matches_data
WHERE team1 IS NULL OR team2 IS NULL;


-- 12. Check matches with no winner (abandoned / no result)

SELECT match_id, season_id, city, result
FROM ipl_matches_data
WHERE match_winner IS NULL;