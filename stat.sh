#!/usr/bin/env bash

echo "Addresses:"
/home/jboss/master/bin/artemis address show --url tcp://${HOSTNAME}:61616
echo " "
echo "Queue status:"
/home/jboss/master/bin/artemis queue stat --url tcp://${HOSTNAME}:61616
