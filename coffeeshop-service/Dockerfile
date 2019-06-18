####
# Before building the docker image run:
#
# mvn package -Pnative -Dnative-image.docker-build=true
#
###
FROM registry.access.redhat.com/ubi8/ubi-minimal
WORKDIR /work/
COPY target/*-runner /work/application
RUN chmod 775 /work
EXPOSE 8080
CMD ["./application", "-Dquarkus.http.host=0.0.0.0", "-Dme.escoffier.quarkus.coffeeshop.http.BaristaService/mp-rest/url=http://barista-http:8080", "-Dmp.messaging.outgoing.orders.bootstrap.servers=my-cluster-kafka-bootstrap.strimzi.svc:9092", "-Dmp.messaging.incoming.beverages.bootstrap.servers=my-cluster-kafka-bootstrap.strimzi.svc:9092", "-Dmp.messaging.outgoing.queue.bootstrap.servers=my-cluster-kafka-bootstrap.strimzi.svc:9092"]
