#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask for username
echo "Enter your username:"
read USERNAME

# Check if user exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"
else
  USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE user_id=$USER_ID")
  IFS="|" read DB_USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
