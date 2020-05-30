#!/usr/bin/env bash

/home/jboss/master/bin/artemis consumer --data /tmp/consume.data  --destination queue://TEST --url tcp://${HOSTNAME}:61616
cat /tmp/consume.data