#!/bin/bash

#############################################
# Ensures docker/docker-compose are installed
# then sets up network and starts all servers
#############################################

# Check that docker & docker-compose are installed
if ! command -v docker &> /dev/null
then
	echo "Docker install not found. See https://docs.docker.com/engine/install/ubuntu/"
	exit 0
else
  echo $(docker -v)
fi

if ! command -v docker-compose &> /dev/null; then
  echo "docker-compose install not found. See https://docs.docker.com/compose/install/"
  exit 1
else
  echo $(docker-compose -v)
fi



# Create external network for proxy server
isnet=$(docker network ls | grep net | awk {'print $2'})
if [ -z $isnet ]
then
  echo "No network \"net\" found, creating..."
  docker network create net
else
  echo "Netowrk \"net\" already exists"
fi

# start all containers using docker-compose
for d in */ ; do
  echo $d
  (cd $d; docker-compose up -d)
done

