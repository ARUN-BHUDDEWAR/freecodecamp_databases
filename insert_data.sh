#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

game_values=""
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year == "year" ]]
  then
    continue
  fi
  game_values+="('$year', '$round', '$winner', '$opponent', '$winner_goals', '$opponent_goals'),"
done < games.csv
game_values=${game_values%,}

$PSQL "WITH input(year, round, winner, opponent, winner_goals, opponent_goals) AS (VALUES $game_values) INSERT INTO teams(name) SELECT winner FROM input UNION SELECT opponent FROM input ON CONFLICT(name) DO NOTHING; WITH input(year, round, winner, opponent, winner_goals, opponent_goals) AS (VALUES $game_values) INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) SELECT input.year::INT, input.round, winner.team_id, opponent.team_id, input.winner_goals::INT, input.opponent_goals::INT FROM input JOIN teams winner ON winner.name = input.winner JOIN teams opponent ON opponent.name = input.opponent;"
