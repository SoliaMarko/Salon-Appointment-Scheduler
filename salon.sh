#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

DISPLAY_SERVICES() {
  echo "$($PSQL "SELECT service_id, name FROM services")" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  PICK_SERVICE
}
 
PICK_SERVICE() {
  read SERVICE_ID_SELECTED

  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
 
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?\n"
    DISPLAY_SERVICES
  else 
    # ask phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if phone is not in DB
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT="$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"
      echo $INSERT_CUSTOMER_RESULT

      APPOINT_SERVICE $CUSTOMER_NAME $SERVICE_ID_SELECTED $SERVICE_NAME_SELECTED
    
    else 
      APPOINT_SERVICE $CUSTOMER_NAME $SERVICE_ID_SELECTED $SERVICE_NAME_SELECTED
    fi
  fi
}

APPOINT_SERVICE() {
    # ask time
    echo -e "\nWhat time would you like your cut, $1"
    read SERVICE_TIME

    # get customer_id
    CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE name='$1'")"

    # create new appointment
    INSERT_APPOINTMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$2', '$SERVICE_TIME')")";
    echo "I have put you down for a $3 at $SERVICE_TIME, $1."
}

DISPLAY_SERVICES
