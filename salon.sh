#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWelcome to the \"Great Salon\""

MAIN_MENU () {
  [[ -n $1 ]] && echo -e "\n$1"
  SALON_SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SALON_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "Choose your desired service\n"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "That's not a valid service option, please pick a valid option"
  else
    echo -e "\nPlease enter your phone number"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nYou aren't registered yet, please enter your name to register"
      read CUSTOMER_NAME

      REGISTER_USER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    
    echo -e "\nEnter the time of your desired service"
    read SERVICE_TIME
    REGISTER_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

    if [[ "$REGISTER_APPOINTMENT" = 'INSERT 0 1' ]]
    then
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID'")

      echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
