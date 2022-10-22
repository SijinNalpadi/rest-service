#!/bin/bash

status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://54.226.103.56:32337/greeting)

if [[ "$status_code" -ne 200 ]] ; then
  echo "Health check failed" 
  echo "FAILED" > commandResult.txt
  exit 1
  
else
  echo "Health check sucess"
  content=$(curl -s http://54.226.103.56:32337/greeting|jq .content|tr -d '"'|cut -d ',' -f1)
  if [[ "$content" == "Hello" ]] ; then
    echo "API is working"
	echo "FAILED" > commandResult.txt
	exit 1
  else
	echo "FAILED" > commandResult.txt
	exit 1
  fi	
	
fi
