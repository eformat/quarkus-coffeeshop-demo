#!/usr/bin/env bash
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "iced-latte", "name": "clement"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "expresso", "name": "neo"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "mocha", "name": "flore"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "capucinno", "name": "mike"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "americano", "name": "ken"}'
