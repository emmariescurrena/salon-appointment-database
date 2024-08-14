#!/bin/bash

PSQL="psql \
    --username=freecodecamp \
    --dbname=salon \
    -t \
    --no-align \
    --field-separator ' ' \
    --quiet \
    -c" \


declare -a services_ids=()
declare -a services_names=()

{
while IFS=\' read -r service_id name
do

    services_ids+=( $service_id )
    services_names+=( $name )

done
}< <(printf '%s\n' "$($PSQL "select * from services")")

while [ -z $SERVICE_ID_SELECTED ] ;
do {

  for id in "${services_ids[@]}"
  do
    echo "$id) ${services_names[$id-1]}"
  done

  read SERVICE_ID_SELECTED
  if ! [[ ${services_ids[@]} =~ $SERVICE_ID_SELECTED ]]
  then
    echo
    echo "Service not found"
    SERVICE_ID_SELECTED=
  fi
} done

echo "Insert phone number:"
read CUSTOMER_PHONE
REGISTERED_CUSTOMER_ID=$($PSQL "select * from customers where phone = '$CUSTOMER_PHONE'")
if [ -z $REGISTERED_CUSTOMER_ID ]
then
echo "You are not registered. Insert name:"
read CUSTOMER_NAME
$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
else
CUSTOMER_ID=$REGISTERED_CUSTOMER_ID
CUSTOMER_NAME=$($PSQL "select name from customers where id = '$CUSTOMER_ID'")
fi

echo "Insert service time:"
read SERVICE_TIME

$($PSQL "insert into appointments(customer_id, service_id, time)
values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo "I have put you down for a ${services_names[$SERVICE_ID_SELECTED-1]} at $SERVICE_TIME, $CUSTOMER_NAME."


