#!/bin/bash
PSQL="psql -X --tuples-only salon freecodecamp -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

DISPLAY_SERVICES() {
  QUERY="SELECT service_id,
    name
  FROM services
  ORDER BY service_id;"
  echo "$($PSQL "$QUERY")" | while read SERVICE_ID BAR SERVICE; do
    echo "$SERVICE_ID) $SERVICE"
  done
}

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi

  DISPLAY_SERVICES

  read SERVICE_ID_SELECTED
  if [[ -z $SERVICE_ID_SELECTED ]]; then
    MAIN_MENU "No service was selected. What would you like today?"
  elif [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "Invalid selection. What would you like today?"
  else
    QUERY="SELECT name
    FROM services
    WHERE service_id = $SERVICE_ID_SELECTED;"
    SERVICE=$($PSQL "$QUERY")
    if [[ -z $SERVICE ]]; then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      QUERY="SELECT customer_id,
        name
      FROM customers
      WHERE phone = '$CUSTOMER_PHONE';"
      CUSTOMER_INFO=$($PSQL "$QUERY")

      CUSTOMER_ID=$(echo $CUSTOMER_INFO | sed -E 's/\s+|\|.*//g')
      CUSTOMER_NAME=$(echo $CUSTOMER_INFO | sed -E 's/.*\||\s+//g')

      if [[ -z $CUSTOMER_ID ]]; then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        INSERT="INSERT INTO customers (name, phone)
        VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
        CUSTOMER_INSERT_RESULT=$($PSQL "$INSERT")

        QUERY="SELECT customer_id
        FROM customers
        WHERE phone='$CUSTOMER_PHONE';"
        CUSTOMER_ID=$($PSQL "$QUERY")
      fi

      echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"

      read SERVICE_TIME

      INSERT="INSERT INTO appointments(time, customer_id, service_id)
      VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED);"
      INSERT_APPOINTMENT_RESULT=$($PSQL "$INSERT")

      echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
