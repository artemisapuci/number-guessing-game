#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask for username
echo "Enter your username:"
read USERNAME

# Strip whitespace
USERNAME=$(echo "$USERNAME" | xargs)

# Check if user exists
USER_INFO=$($PSQL "SELECT user_id, TRIM(username), games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]; then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # Returning user
  IFS="|" read USER_ID DB_USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate secret number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

while true; do
  read GUESS
  ((NUMBER_OF_GUESSES++))

  # Check if input is an integer
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    break
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Update stats
USER_STATS=$($PSQL "SELECT games_played, best_game FROM users WHERE user_id=$USER_ID")
IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_STATS"
NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))

if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
  $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE user_id=$USER_ID" > /dev/null
else
  $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE user_id=$USER_ID" > /dev/null
fi
