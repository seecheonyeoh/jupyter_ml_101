#!/bin/bash
 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
 
CONTAINER_ID=`docker run -d --rm \
  -v $DIR/..:/home/jovyan/work \
  -e GRANT_SUDO=yes \
  -p 8888:8888 -p 4040:4040 \
  jupyter/datascience-notebook`

echo $CONTAINER_ID
 
C_STARTED=false
 
echo "Waiting for container to start..."
for i in {1..10}
do
    sleep 1
    START_INSPECT=`docker inspect $CONTAINER_ID | grep "running"`
 
    if [ ! -z "$START_INSPECT" ]
    then
        C_STARTED=true
        break
    fi
done
 
if [ ! $C_STARTED ]
then
    echo "Fail to start container"
    exit 1
fi
 
echo "Launching browser..."
 
for i in {1..10}
do
    LOGS=$(docker logs $CONTAINER_ID 2>&1 > /dev/null | grep token | head -1)
    JUPYTER_TOKEN=`expr "$LOGS" : '.*token=\(.*\)'`
 
    if [ ! -z "$JUPYTER_TOKEN" ]
    then
        open http://localhost:8888/?token=$JUPYTER_TOKEN
        exit 0
    fi   
 
    sleep 1
done
 
echo "Could not obtain Jupyter token to launch browser!"
