FROM amazoncorretto:11-alpine-jdk as builder

WORKDIR /cloudwatch_exporter

COPY . .

RUN apk add --no-cache maven \
    && mvn package \
    && mv target/cloudwatch_exporter-*-with-dependencies.jar /cloudwatch_exporter.jar

FROM amazoncorretto:11-alpine
MAINTAINER Prometheus Team <prometheus-developers@googlegroups.com>

EXPOSE 9106

RUN mkdir /config \
    && addgroup -S exporter \
    && adduser -S exporter -G exporter
USER exporter

COPY --from=builder --chown=exporter:exporter /cloudwatch_exporter.jar .

ENTRYPOINT [ "java", "-jar", "/cloudwatch_exporter.jar", "9106"]
CMD ["/config/config.yml"]
