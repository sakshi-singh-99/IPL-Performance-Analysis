
# ============================================================
# IPL Performance Analysis
# Load SQL Query Results into Pandas
#
# This script executes analysis queries from SQL Server and
# loads the results into pandas DataFrames. These DataFrames
# will be used later for visualization and insights.
# ============================================================

import pandas as pd
from sqlalchemy import text
from database_connection import engine


# ------------------------------------------------------------
# Helper function to execute query and return DataFrame
# ------------------------------------------------------------
def load_query(query):
    with engine.connect() as conn:
        df = pd.read_sql(text(query), conn)
    return df


# ============================================================
# MATCH ANALYSIS DATA
# ============================================================

# Matches per season
matches_per_season = load_query("""
SELECT season_id, COUNT(DISTINCT match_id) AS total_matches
FROM dbo.ipl_matches_data
GROUP BY season_id
ORDER BY season_id
""")


# Average first innings score per season
avg_first_innings_score = load_query("""
WITH first_innings_score AS (
    SELECT match_id, season_id, SUM(total_runs) AS first_innings_runs
    FROM dbo.ball_by_ball_data
    WHERE innings = 1
    GROUP BY match_id, season_id
)
SELECT season_id,
ROUND(AVG(first_innings_runs),2) AS avg_first_innings_score
FROM first_innings_score
GROUP BY season_id
ORDER BY season_id
""")


# Winning type distribution
match_result_type = load_query("""
SELECT
CASE
    WHEN TRY_CAST(win_by_runs AS INT) > 0 THEN 'Defending Team Won'
    WHEN TRY_CAST(win_by_wickets AS INT) > 0 THEN 'Chasing Team Won'
    ELSE 'No Result'
END AS match_result_type,
COUNT(*) AS total_matches
FROM dbo.ipl_matches_data
GROUP BY
CASE
    WHEN TRY_CAST(win_by_runs AS INT) > 0 THEN 'Defending Team Won'
    WHEN TRY_CAST(win_by_wickets AS INT) > 0 THEN 'Chasing Team Won'
    ELSE 'No Result'
END
""")


# ============================================================
# BATTING DATA
# ============================================================

top_batters = load_query("""
SELECT batter, SUM(TRY_CAST(batter_runs AS INT)) AS total_runs
FROM dbo.ball_by_ball_data
GROUP BY batter
ORDER BY total_runs DESC
""")


strike_rate = load_query("""
SELECT
batter,
SUM(TRY_CAST(batter_runs AS INT)) AS total_runs,
COUNT(*) AS balls_faced,
ROUND(SUM(TRY_CAST(batter_runs AS INT)) * 100.0 / COUNT(*),2) AS strike_rate
FROM dbo.ball_by_ball_data
WHERE is_wide_ball = 0
GROUP BY batter
ORDER BY strike_rate DESC
""")


# ============================================================
# BOWLING DATA
# ============================================================

top_bowlers = load_query("""
SELECT bowler, COUNT(*) AS total_wickets
FROM dbo.ball_by_ball_data
WHERE is_wicket = 1
GROUP BY bowler
ORDER BY total_wickets DESC
""")


economy_rate = load_query("""
WITH bowler_runs AS (
SELECT bowler,
SUM(TRY_CAST(total_runs AS INT)) AS runs_conceded,
COUNT(*) AS balls_bowled
FROM dbo.ball_by_ball_data
WHERE is_wide_ball = 0 AND is_no_ball = 0
GROUP BY bowler
)
SELECT bowler,
ROUND(runs_conceded / (balls_bowled / 6.0),2) AS economy_rate
FROM bowler_runs
ORDER BY economy_rate ASC
""")


# ============================================================
# TEAM PERFORMANCE
# ============================================================

team_win_percentage = load_query("""
SELECT
m.team_name,
w.total_wins,
m.total_matches,
ROUND((CAST(w.total_wins AS FLOAT) / m.total_matches) * 100,2) AS win_percentage
FROM
(
SELECT team_name, COUNT(*) AS total_matches
FROM (
SELECT team1 AS team_name FROM dbo.ipl_matches_data
UNION ALL
SELECT team2 AS team_name FROM dbo.ipl_matches_data
) t
GROUP BY team_name
) m
LEFT JOIN
(
SELECT match_winner AS team_name, COUNT(*) AS total_wins
FROM dbo.ipl_matches_data
WHERE match_winner IS NOT NULL
GROUP BY match_winner
) w
ON m.team_name = w.team_name
ORDER BY win_percentage DESC
""")


# ============================================================
# TOSS IMPACT
# ============================================================

toss_win_percentage = load_query("""
SELECT
ROUND(
COUNT(CASE WHEN toss_winner = match_winner THEN 1 END) * 100.0
/ COUNT(*),2) AS toss_win_percentage
FROM dbo.ipl_matches_data
WHERE toss_winner IS NOT NULL AND match_winner IS NOT NULL
""")


# ============================================================
# PLAYER IMPACT
# ============================================================

player_of_match = load_query("""
SELECT player_of_match AS player, COUNT(*) AS total_awards
FROM dbo.ipl_matches_data
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY total_awards DESC
""")


# ------------------------------------------------------------
# Quick preview when file executed directly
# ------------------------------------------------------------
if __name__ == "__main__":
    print("\nMatches Per Season:")
    print(matches_per_season.head())

    print("\nTop Batters:")
    print(top_batters.head())

    print("\nTop Bowlers:")
    print(top_bowlers.head())