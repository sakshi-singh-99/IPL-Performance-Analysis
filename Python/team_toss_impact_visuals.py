# team_toss_impact_visuals.py
# very simple team & toss analysis

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sqlalchemy import text
from database_connection import engine

sns.set_style("whitegrid")
plt.rcParams["figure.figsize"] = (10,5)

print("Connection Successful")
print("Loading team & toss impact data from SQL Server...")


# --------------------------------------------------
# 1. Toss decision distribution
# --------------------------------------------------
toss_decision_query = text("""
SELECT toss_decision, COUNT(*) AS total
FROM dbo.ipl_matches_data
GROUP BY toss_decision
""")

toss_decision = pd.read_sql(toss_decision_query, engine)

plt.figure()
sns.barplot(x="toss_decision", y="total", data=toss_decision)
plt.title("Toss Decision Distribution")
plt.xlabel("Decision")
plt.ylabel("Matches")
plt.tight_layout()
plt.show()


# --------------------------------------------------
# 2. Toss winner vs match winner
# --------------------------------------------------
toss_win_query = text("""
SELECT 
CASE 
    WHEN toss_winner = match_winner THEN 'Won Match'
    ELSE 'Lost Match'
END AS result,
COUNT(*) AS total
FROM dbo.ipl_matches_data
GROUP BY 
CASE 
    WHEN toss_winner = match_winner THEN 'Won Match'
    ELSE 'Lost Match'
END
""")

toss_win = pd.read_sql(toss_win_query, engine)

plt.figure()
sns.barplot(x="result", y="total", data=toss_win)
plt.title("Did Toss Winner Win the Match?")
plt.xlabel("Result")
plt.ylabel("Matches")
plt.tight_layout()
plt.show()


# --------------------------------------------------
# 3. Most successful teams
# --------------------------------------------------
team_wins_query = text("""
SELECT TOP 10 match_winner AS team, COUNT(*) AS wins
FROM dbo.ipl_matches_data
GROUP BY match_winner
ORDER BY wins DESC
""")

team_wins = pd.read_sql(team_wins_query, engine)

plt.figure()
sns.barplot(x="wins", y="team", data=team_wins)
plt.title("Top Winning Teams")
plt.xlabel("Wins")
plt.ylabel("Team")
plt.tight_layout()
plt.show()


print("Team & Toss impact visualizations generated successfully.")