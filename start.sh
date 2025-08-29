#!/bin/sh

if [ ! -f ./eula.txt ]; then
    echo "eula=true" > ./eula.txt
fi

/usr/bin/java -jar /opt/paper/paper-server.jar
