# Coffeeshop Demo with Quarkus

This directory contains a set of demo around _reactive_ in Quarkus with Kafka.
It demonstrates the elasticity and resilience of the system.

## Build

```bash
mvn clean package
```

## Prerequisites

Run Kafka with:

```bash
docker-compose up
```

Then, create the `orders` topic with (need this for multiple partitions)

```
`./create-orders.sh`
```

# Run the demo

You need to run:

* the coffee shop service
* the HTTP barista
* the Kafka barista

Im 3 terminals: 

```bash
cd coffeeshop-service
mvn compile quarkus:dev
```

```bash
cd barista-http
mvn compile quarkus:dev
```

```bash
cd barista-kafka
mvn compile quarkus:dev
```

# Execute with HTTP

The first part of the demo shows HTTP interactions:

* Barista code: `me.escoffier.quarkus.coffeeshop.BaristaResource`
* CoffeeShop code: `me.escoffier.quarkus.coffeeshop.CoffeeShopResource.http`
* Generated client: `me.escoffier.quarkus.coffeeshop.http.BaristaService`

Important points:
* Request-reply

Order coffees with:

```bash
curl -X POST -H "Content-Type: application/json" http://localhost:8080/http -d '{"product": "latte", "name": "clement"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/http -d '{"product": "expresso", "name": "neo"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/http -d '{"product": "mocha", "name": "flore"}'
```

Stop the HTTP Barista, you can't order coffee anymore.

# Execute with Kafka

* Barista code: `me.escoffier.quarkus.coffeeshop.KafkaBarista`: Read from `orders`, write to `queue`
* Bridge in the CoffeeShop: `me.escoffier.quarkus.coffeeshop.messaging.KafkaBaristas` just enqueue the orders in a single thread (one counter)
* Get prepared beverages on `me.escoffier.quarkus.coffeeshop.dashboard.BoardResource` and send to SSE

* Open browser to http://localhost:8080/queue
* Order coffee with:

```bash
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "latte", "name": "clement"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "expresso", "name": "neo"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "mocha", "name": "flore"}'
```

# Baristas do breaks

Stop the Kafka barista

Continue to enqueue order

```
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "latte", "name": "clement"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "expresso", "name": "neo"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "mocha", "name": "flore"}'
```

On the dashboard, the orders are in the "IN QUEUE" state

Restart the barista

They are processed

# 2 baristas are better

Start a second barista with: 
```bash
java -Dquarkus.http.port=9095 -Dbarista.name=tom -jar target/barista-kafka-1.0-SNAPSHOT-runner.jar
```

Order more coffee
```bash
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "latte", "name": "clement"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "expresso", "name": "neo"}'
curl -X POST -H "Content-Type: application/json" http://localhost:8080/messaging -d '{"product": "mocha", "name": "flore"}'
```

The dashboard shows that the load is dispatched among the baristas.
