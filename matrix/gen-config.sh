#!/bin/bash

TYPE=bind  # volume
VOLUME_SRC="/mnt/data/all/matrix" #matrix-synapse-data # Match name to docker-compose naming scheme for volumes
SERVER_NAME=matrix.reclusivy.com
PORT=8008

docker run -it --rm \
    --mount type=$TYPE,src=$VOLUME_SRC,dst=/data \
    -e SYNAPSE_SERVER_NAME=$SERVER_NAME \
    -e SYNAPSE_REPORT_STATS=yes \
    -e SYNAPSE_HTTP_PORT=$PORT \
    matrixdotorg/synapse:v1.99.0 generate

#docker run -it --rm --mount type=volume,src=synapse-data,dst=/data -e SYNAPSE_SERVER_NAME=my.matrix.host -e SYNAPSE_REPORT_STATS=yes matrixdotorg/synapse:latest generate
