#!/bin/bash

echo -e '\n~~~~~ MY SALON ~~~~~'

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # echo -e '1) cut\n2) color\n3) perm\n4) style\n5) trim'
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  # サービスIDを配列に保存
  SERVICE_IDS=()
  while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
    SERVICE_IDS+=("$SERVICE_ID")
  done <<< "$SERVICES"

  read SERVICE_ID_SELECTED

  if [[ " ${SERVICE_IDS[*]} " =~ " $SERVICE_ID_SELECTED " ]]; then
    SELECTED_SERVICE=$($PSQL "
      SELECT name FROM services
        WHERE service_id = $SERVICE_ID_SELECTED
    ")

    MAKE_APPOINTMENT
  else
    MAIN_MENU "I could not find that service. What would you like today?"
  fi
}

MAKE_APPOINTMENT(){
  echo "What's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "
    SELECT customer_id 
    FROM customers
      WHERE phone = '$CUSTOMER_PHONE'
  ")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "
      INSERT INTO customers(phone, name) 
        VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')
    ")
  fi

  CUSTOMER_ID=$($PSQL "
    SELECT customer_id 
    FROM customers
      WHERE phone = '$CUSTOMER_PHONE'
  ")

  echo -e "\nWhat time would you like your cut, Fabio?"
  read SERVICE_TIME

  INSERT_APPINTMENTS_RESULT=$($PSQL "
    INSERT INTO appointments(customer_id, service_id, time)
      VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')
  ")

  echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

}

MAIN_MENU "Welcome to My Salon, how can I help you?"