#!/bin/bash

# salon appointment scheduler

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n<---{ Salon Services }--->\n"

SERVICES()
      {
        if [[ $1 ]]
        then echo -e "\n$1"
        fi

        echo Please select a service...

        SERVICES=$($PSQL "SELECT service_id, name FROM services")
        echo "$SERVICES" | while read SERVICE_ID BAR NAME
                            do
        echo "$SERVICE_ID) $NAME"
                            done
        echo "5) Exit"

        read SERVICE_ID_SELECTED

        case $SERVICE_ID_SELECTED in
         1 | 2 | 3 | 4) SET_APPOINTMENT ;;
        *) SERVICES "You must select 1-4, or 5.\n" ;;
        esac
      }

      SET_APPOINTMENT()
            {
              # get phone
              echo -e "\nPlease enter your phone number."
              read CUSTOMER_PHONE

              CUSTOMER_NAME=$($PSQL "Select name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

              # if new customer get name            
              if [[ -z $CUSTOMER_NAME ]]
              then echo -e "\nPlease enter your name."
              read CUSTOMER_NAME
              # insert new customer
              INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
              fi              
              # get service time
              echo -e "\nWhat time would you like? Please use HH:mm format."
              read SERVICE_TIME
              # insert appointment
              CUSTOMER_ID_FETCH=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
              INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, time, customer_id) VALUES ($SERVICE_ID_SELECTED, '$SERVICE_TIME', $CUSTOMER_ID_FETCH)")
              # appointment added "I have put you down for a [service] at [time], [name]." and send to menu
              SERVICES_CONFIRMATION_INFO=$($PSQL "SELECT services.name, time FROM services INNER JOIN appointments USING(service_id) INNER JOIN customers USING(customer_id) WHERE customer_id = $CUSTOMER_ID_FETCH AND time = '$SERVICE_TIME'")
              SERVICES_INFO_FORMATTED=$(echo $SERVICES_CONFIRMATION_INFO | sed 's/ | / at /g')

              echo -e "\nI have put you down for a $SERVICES_INFO_FORMATTED, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g').\n"
              EXIT
            }
      
EXIT()
      {
        echo -e "\nGoodbye."
      }

SERVICES
