# ============================================================
# batting_bowling_visuals.py
# Player Batting & Bowling Performance Analysis
# ============================================================

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import text
from database_connection import engine

sns.set_style("whitegrid")
plt.rcParams["figure.figsize"] = (12,6)

print("Loading batting & bowling data from SQL Server...")


# ============================================================
# 1. TOP RUN SCORERS
# ============================================================

top_runs_query = text("""
SELECT TOP 10
    batter AS player_name,
    SUM(TRY_CAST(batter_runs AS INT)) AS total_runs
FROM dbo.ball_by_ball_data
GROUP BY batter
ORDER BY total_runs DESC
""")

top_runs = pd.read_sql(top_runs_query, engine)

plt.figure()
sns.barplot(data=top_runs, x="total_runs", y="player_name",
            hue="player_name", legend=False, palette="viridis")

plt.title("Top 10 Run Scorers")
plt.xlabel("Runs")
plt.ylabel("Player")
plt.tight_layout()
plt.show()



# ============================================================
# 2. BEST STRIKE RATE (MIN 500 BALLS)
# ============================================================

strike_rate_query = text("""
SELECT TOP 10
    batter AS player_name,
    SUM(TRY_CAST(batter_runs AS FLOAT)) / COUNT(*) * 100 AS strike_rate
FROM dbo.ball_by_ball_data
GROUP BY batter
HAVING COUNT(*) >= 500
ORDER BY strike_rate DESC
""")

strike_rate = pd.read_sql(strike_rate_query, engine)

plt.figure()
sns.barplot(data=strike_rate, x="strike_rate", y="player_name",
            hue="player_name", legend=False, palette="magma")

plt.title("Best Strike Rate (Min 500 Balls)")
plt.xlabel("Strike Rate")
plt.ylabel("Player")
plt.tight_layout()
plt.show()



# ============================================================
# 3. MOST WICKETS
# ============================================================

wickets_query = text("""
SELECT TOP 10
    bowler AS player_name,
    COUNT(*) AS wickets
FROM dbo.ball_by_ball_data
WHERE is_wicket = 1
GROUP BY bowler
ORDER BY wickets DESC
""")

top_wickets = pd.read_sql(wickets_query, engine)

plt.figure()
sns.barplot(data=top_wickets, x="wickets", y="player_name",
            hue="player_name", legend=False, palette="coolwarm")

plt.title("Top 10 Wicket Takers")
plt.xlabel("Wickets")
plt.ylabel("Bowler")
plt.tight_layout()
plt.show()



# ============================================================
# 4. BEST ECONOMY (MIN 300 BALLS)
# ============================================================

economy_query = text("""
SELECT TOP 10
    bowler AS player_name,
    SUM(TRY_CAST(total_runs AS FLOAT)) / (COUNT(*)/6.0) AS economy
FROM dbo.ball_by_ball_data
GROUP BY bowler
HAVING COUNT(*) >= 300
ORDER BY economy ASC
""")

economy = pd.read_sql(economy_query, engine)

plt.figure()
sns.barplot(data=economy, x="economy", y="player_name",
            hue="player_name", legend=False, palette="cubehelix")

plt.title("Best Economy Rate (Min 300 Balls)")
plt.xlabel("Economy")
plt.ylabel("Bowler")
plt.tight_layout()
plt.show()



# ============================================================
# 5. MOST PLAYER OF MATCH AWARDS
# ============================================================

pom_query = text("""
SELECT TOP 10
    player_of_match AS player_name,
    COUNT(*) AS awards
FROM dbo.ipl_matches_data
GROUP BY player_of_match
ORDER BY awards DESC
""")

pom = pd.read_sql(pom_query, engine)

plt.figure()
sns.barplot(data=pom, x="awards", y="player_name",
            hue="player_name", legend=False, palette="Set2")

plt.title("Most Player of the Match Awards")
plt.xlabel("Awards")
plt.ylabel("Player")
plt.tight_layout()
plt.show()



# ============================================================
# 6. MOST RUNS BY TEAM
# ============================================================

team_runs_query = text("""
SELECT TOP 10
    team_batting AS team_name,
    SUM(TRY_CAST(total_runs AS INT)) AS total_runs
FROM dbo.ball_by_ball_data
GROUP BY team_batting
ORDER BY total_runs DESC
""")

team_runs = pd.read_sql(team_runs_query, engine)

plt.figure()
sns.barplot(data=team_runs, x="total_runs", y="team_name",
            hue="team_name", legend=False, palette="flare")

plt.title("Top Teams by Total Runs")
plt.xlabel("Runs")
plt.ylabel("Team")
plt.tight_layout()
plt.show()


print("\nBatting & Bowling visualizations generated successfully.")
