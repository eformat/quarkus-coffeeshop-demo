#!/usr/bin/env bash
java -Dbarista.name=julie \
     -Dquarkus.http.port=9096 \
     -Dmp.messaging.incoming.orders.client.id=julie \
     -jar target/barista-kafka-1.0-SNAPSHOT-runner.jar
