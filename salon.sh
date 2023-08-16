#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

GET_ID() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-5]) SCHEDULE ;;
        *) GET_ID "I could not find that service. What would you like today?" ;;
  esac
}

SCHEDULE() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
 #get name based on number entered
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    
    INSERT_CUSTOMERS=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENTS == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

GET_ID
