#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Truncate tables
echo $($PSQL "TRUNCATE teams, games;")

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  if [[ $YEAR != "year" ]]
  then
    # check if team_id exists
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    # TEAM_ID_WINNER does not exists
    if [[ -z $TEAM_ID_WINNER ]]
    then
      INSERT_ID_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      
      if [[ $INSERT_ID_WINNER == "INSERT 0 1" ]]
      then
        TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
        echo Created a new team id for: $WINNER 
      fi
    fi

    # TEAM_ID_OPPONENT does not exist
    if [[ -z $TEAM_ID_OPPONENT ]]
    then
      INSERT_ID_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $INSERT_ID_OPPONENT == "INSERT 0 1" ]]
      then
        TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
        echo Created a new team id for: $OPPONENT
      fi
    fi

    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ $INSERT_GAME = "INSERT 0 1" ]]
    then
      echo Inserted game $WINNER vs $OPPONENT
    fi

  fi
done