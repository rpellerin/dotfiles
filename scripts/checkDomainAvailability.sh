#!/bin/bash

# CHECK WHETHER A GIVEN DOMAIN NAME WITH NO TLD IS AVAILABLE OR NOT
# Author: Romain PELLERIN <contact@romainpellerin.eu>
# Original script: http://linuxconfig.org/check-domain-name-availability-with-bash-and-whois
#
# REQUIREMENTS
# whois
#
# ARGUMENT TO PASS
# 1- The domain name without the top-level domain
# Example: ./checkDomainAvailability.sh google
 
if [ "$#" -eq 0 ]; then
    echo "You need tu supply at least one argument!" 
    exit 1
fi 
 
DOMAINS=(".com" ".net" ".me" ".eu" ".fr" ".name")
 
ELEMENTS=${#DOMAINS[@]} 
 
while (( "$#" )); do 
  for (( i=0;i<$ELEMENTS;i++)); do
      RES=`whois $1${DOMAINS[${i}]}`
      echo $RES | egrep -iq '^No match|^NOT FOUND|^[^%].*AVAILABLE|^No Data Fou|has not been regi|No entri' 
	  if [ $? -eq 0 ]; then 
	      echo "$1${DOMAINS[${i}]} : available"
	      notify-send "$1${DOMAINS[${i}]} is available!"
	  else
 	      echo "$1${DOMAINS[${i}]} : not available"
              DATE=`echo "$RES" |grep -i 'expiration' |awk 'length($0)<50'`
	      if [ -n "$DATE" ]; then
	          echo -n "      >>> "
	          echo $DATE
	      fi
	  fi 
  done 
shift
done