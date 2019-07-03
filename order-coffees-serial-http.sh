#!/usr/bin/env bash
SHOPURL=${SHOPURL-localhost:8080}

curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/http -d '{"product": "iced-latte", "name": "clement"}' && echo
curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/http -d '{"product": "expresso", "name": "neo"}' && echo
curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/http -d '{"product": "mocha", "name": "flore"}' && echo
curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/http -d '{"product": "capucinno", "name": "mike"}' && echo
curl -X POST -H "Content-Type: application/json" http://${SHOPURL}/http -d '{"product": "americano", "name": "ken"}' && echo
