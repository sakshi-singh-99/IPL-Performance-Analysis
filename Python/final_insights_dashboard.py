import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import create_engine
import urllib

# =========================
# DATABASE CONNECTION
# =========================

params = urllib.parse.quote_plus(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=INSPIRON;"
    "DATABASE=IPL Analysis DB;"
    "Trusted_Connection=yes;"
)

engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

print("Connection Successful")

# =========================
# LOAD DATA
# =========================

def load_data():
    print("Loading final dashboard data from SQL Server...")

    matches_query = """
    SELECT team1, team2, match_winner, toss_winner, toss_decision, win_by_runs, win_by_wickets
    FROM dbo.ipl_matches_data
    """

    balls_query = """
    SELECT team_batting, team_bowling, total_runs, is_wicket
    FROM dbo.ball_by_ball_data
    """

    matches = pd.read_sql(matches_query, engine)
    balls = pd.read_sql(balls_query, engine)

    return matches, balls

# =========================
# VISUAL 1 — MOST WINS
# =========================

def plot_team_wins(matches):
    wins = matches['match_winner'].value_counts().head(10)

    plt.figure(figsize=(10,5))
    sns.barplot(x=wins.values, y=wins.index)
    plt.title("Top 10 Teams by Total Wins")
    plt.xlabel("Wins")
    plt.ylabel("Team")
    plt.tight_layout()
    plt.show()

# =========================
# VISUAL 2 — AVG RUNS SCORED
# =========================

def plot_avg_runs(balls):
    avg_runs = balls.groupby('team_batting')['total_runs'].mean().sort_values(ascending=False).head(10)

    plt.figure(figsize=(10,5))
    sns.barplot(x=avg_runs.values, y=avg_runs.index)
    plt.title("Top 10 Teams by Average Runs per Ball")
    plt.xlabel("Average Runs")
    plt.ylabel("Batting Team")
    plt.tight_layout()
    plt.show()

# =========================
# VISUAL 3 — TOSS IMPACT
# =========================

def plot_toss_impact(matches):
    matches['toss_win_match_win'] = matches['toss_winner'] == matches['match_winner']

    toss_impact = matches['toss_win_match_win'].value_counts()

    plt.figure(figsize=(6,6))
    plt.pie(toss_impact, labels=['Lost After Toss Win','Won After Toss Win'], autopct='%1.1f%%')
    plt.title("Does Winning Toss Help Win Match?")
    plt.show()

# =========================
# VISUAL 4 — WICKETS BY TEAM
# =========================

def plot_wickets(balls):
    wickets = balls[balls['is_wicket'] == 1]
    wickets = wickets['team_bowling'].value_counts().head(10)

    plt.figure(figsize=(10,5))
    sns.barplot(x=wickets.values, y=wickets.index)
    plt.title("Top 10 Teams by Wickets Taken")
    plt.xlabel("Wickets")
    plt.ylabel("Bowling Team")
    plt.tight_layout()
    plt.show()

# =========================
# MAIN
# =========================

def main():
    matches, balls = load_data()

    plot_team_wins(matches)
    plot_avg_runs(balls)
    plot_toss_impact(matches)
    plot_wickets(balls)

    print("Final Dashboard Generated Successfully")

if __name__ == "__main__":
    main()