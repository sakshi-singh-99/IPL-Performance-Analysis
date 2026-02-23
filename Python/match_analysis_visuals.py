# ============================================================
# match_analysis_visuals.py
# Match level visual analysis charts from IPL SQL database
# ============================================================

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import text
from database_connection import engine

sns.set_style("whitegrid")
plt.rcParams["figure.figsize"] = (12,6)


# ============================================================
# LOAD MATCH TABLE ONCE (and fix datatypes)
# ============================================================

print("Loading dataset from SQL Server...")

matches_df = pd.read_sql(text("SELECT * FROM dbo.ipl_matches_data"), engine)

# ---- FIX DATATYPES (IMPORTANT) ----
matches_df["win_by_runs"] = pd.to_numeric(matches_df["win_by_runs"], errors="coerce").fillna(0)
matches_df["win_by_wickets"] = pd.to_numeric(matches_df["win_by_wickets"], errors="coerce").fillna(0)


# ============================================================
# 1. MATCHES PER SEASON
# ============================================================

matches_per_season = (
    matches_df.groupby("season_id")["match_id"]
    .count()
    .reset_index(name="total_matches")
)

plt.figure()
sns.barplot(data=matches_per_season,
            x="season_id", y="total_matches",
            hue="season_id", legend=False)

plt.title("Matches Played Per IPL Season")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()



# ============================================================
# 2. TOP 10 BATTERS
# ============================================================

top_batters = pd.read_sql(text("""
SELECT TOP 10 batter, SUM(CAST(batter_runs AS INT)) AS total_runs
FROM dbo.ball_by_ball_data
GROUP BY batter
ORDER BY total_runs DESC
"""), engine)

plt.figure()
sns.barplot(data=top_batters, x="total_runs", y="batter", hue="batter", legend=False)
plt.title("Top 10 Run Scorers in IPL")
plt.tight_layout()
plt.show()



# ============================================================
# 3. TOP 10 BOWLERS
# ============================================================

top_bowlers = pd.read_sql(text("""
SELECT TOP 10 bowler, COUNT(*) AS total_wickets
FROM dbo.ball_by_ball_data
WHERE is_wicket = 1
GROUP BY bowler
ORDER BY total_wickets DESC
"""), engine)

plt.figure()
sns.barplot(data=top_bowlers, x="total_wickets", y="bowler", hue="bowler", legend=False)
plt.title("Top 10 Wicket Takers in IPL")
plt.tight_layout()
plt.show()



# ============================================================
# 4. CHASING VS DEFENDING (NOW WORKS)
# ============================================================

matches_df["match_result"] = matches_df.apply(
    lambda x: "Defending Team Won" if x.win_by_runs > 0
    else ("Chasing Team Won" if x.win_by_wickets > 0 else "No Result"),
    axis=1
)

chase_defend = matches_df["match_result"].value_counts().reset_index()
chase_defend.columns = ["match_result", "matches"]

plt.figure()
sns.barplot(data=chase_defend, x="match_result", y="matches", hue="match_result", legend=False)
plt.title("Chasing vs Defending Wins")
plt.xticks(rotation=20)
plt.tight_layout()
plt.show()



# ============================================================
# 5. AVG RUNS SCORED BY WINNING TEAMS
# ============================================================

top_avg_win = pd.read_sql(text("""
SELECT TOP 10
    m.match_winner,
    ROUND(AVG(CAST(b.total_runs AS FLOAT)),2) AS avg_runs_scored
FROM dbo.ball_by_ball_data b
JOIN dbo.ipl_matches_data m ON b.match_id = m.match_id
WHERE b.team_batting = m.match_winner
GROUP BY m.match_winner
ORDER BY avg_runs_scored DESC
"""), engine)

plt.figure()
sns.barplot(data=top_avg_win, x="avg_runs_scored", y="match_winner", hue="match_winner", legend=False)
plt.title("Average Runs Scored by Winning Teams")
plt.tight_layout()
plt.show()



# ============================================================
# 6. TOSS IMPACT
# ============================================================

matches_df["toss_result"] = matches_df.apply(
    lambda x: "Toss Winner Won" if x.toss_winner == x.match_winner else "Toss Winner Lost",
    axis=1
)

toss_result = matches_df["toss_result"].value_counts().reset_index()
toss_result.columns = ["toss_result", "total_matches"]

plt.figure()
sns.barplot(data=toss_result, x="toss_result", y="total_matches", hue="toss_result", legend=False)
plt.title("Impact of Toss on Match Result")
plt.tight_layout()
plt.show()



# ============================================================
# 7. FIRST INNINGS TREND
# ============================================================

first_innings = pd.read_sql(text("""
WITH first_innings AS (
SELECT m.season_id, b.match_id,
SUM(CAST(b.total_runs AS INT)) AS runs
FROM dbo.ball_by_ball_data b
JOIN dbo.ipl_matches_data m ON b.match_id = m.match_id
WHERE b.innings = 1
GROUP BY m.season_id, b.match_id
)
SELECT season_id, AVG(runs) AS avg_score
FROM first_innings
GROUP BY season_id
ORDER BY season_id
"""), engine)

plt.figure()
sns.lineplot(data=first_innings, x="season_id", y="avg_score", marker="o")
plt.title("Average First Innings Score Trend")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()


print("\nAll visualizations generated successfully.")