#!/bin/bash

status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://54.226.103.56:32337/greeting)

if [[ "$status_code" -ne 200 ]] ; then
  echo "Health check failed" 
  exit 1
  echo "FAILED" > /tmp/status
else
  echo "Health check sucess"
  content=$(curl -s http://54.226.103.56:32337/greeting|jq .content|tr -d '"'|cut -d ',' -f1)
  if [[ "$content" == "Hello" ]] ; then
    echo "API is working"
	exit 0 
	echo "SUCCESS" > /tmp/status
  else
	exit 1
	echo "FAILED" > /tmp/status
  fi	
	
fi
