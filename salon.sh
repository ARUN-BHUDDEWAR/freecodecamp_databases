#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  else
    echo -e "\n~~~~~ MY SALON ~~~~~"
    echo -e "\nWelcome to My Salon, how can I help you?"
  fi

  while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done < <($PSQL -c "SELECT service_id, name FROM services ORDER BY service_id" </dev/null)

  echo
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  SERVICE_NAME=$($PSQL -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" </dev/null)
  if [[ -z $SERVICE_NAME ]]; then
    MAIN_MENU "I could not find that service. What would you like today?"
  fi
}

MAIN_MENU

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" </dev/null)

if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" </dev/null >/dev/null
fi

CUSTOMER_ID=$($PSQL -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" </dev/null)
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
$PSQL -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" </dev/null >/dev/null

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
