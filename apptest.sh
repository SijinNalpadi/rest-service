#!/bin/bash

echo "Waiting For API to be Ready..."
sleep 30
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://34.242.57.126/greeting)

if [[ "$status_code" -ne 200 ]] ; then
  echo "API Health Check Failed..." 
  exit 1
  
else
  echo "API Health Check Success..."
  content=$(curl -s http://34.242.57.126/greeting|jq .content|tr -d '"'|cut -d ',' -f1)
  if [[ "$content" == "Hello" ]] ; then
    echo "API Functionality Check Success..."
    exit 0
  else
    echo "API Functionality is Failed..."
    exit 1
  fi	
	
fi
