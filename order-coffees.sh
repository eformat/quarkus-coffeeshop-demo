#!/usr/bin/env bash
SHOPURL=${SHOPURL-localhost:8080}

curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/messaging -d '{"product": "iced-latte", "name": "clement"}'
curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/messaging -d '{"product": "expresso", "name": "neo"}'
curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/messaging -d '{"product": "mocha", "name": "flore"}'
curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/messaging -d '{"product": "capucinno", "name": "mike"}'
curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/messaging -d '{"product": "americano", "name": "ken"}'
