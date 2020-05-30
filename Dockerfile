# Please see README.md file for how to obtain image
#FROM nexus3.nuc.local:9000/amq7/amq-broker-lts-rhel7:7.5
FROM registry.redhat.io/amq7/amq-broker-lts-rhel7:latest

COPY docker-healthcheck.sh docker-entrypoint.sh logging.properties launch.sh produce.sh consume.sh stat.sh /
USER root
RUN chmod 777 /docker-healthcheck.sh /docker-entrypoint.sh /logging.properties /launch.sh /produce.sh /consume.sh /stat.sh
RUN mkdir /data /backup
RUN chown jboss:jboss /data /backup
USER jboss

EXPOSE 62616 9161
HEALTHCHECK --start-period=20s CMD /docker-healthcheck.sh
CMD /docker-entrypoint.sh
