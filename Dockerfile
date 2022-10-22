FROM openjdk
MAINTAINER Sijin Nalpadi
COPY target/rest-service*.jar rest-service-1.0.0.jar
ENTRYPOINT ["java","-jar","/rest-service-1.0.0.jar"]
