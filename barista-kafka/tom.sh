#!/usr/bin/env bash
java -Dbarista.name=tom \
     -Dquarkus.http.port=9095 \
     -Dmp.messaging.incoming.orders.client.id=tom \
     -jar target/barista-kafka-1.0-SNAPSHOT-runner.jar
