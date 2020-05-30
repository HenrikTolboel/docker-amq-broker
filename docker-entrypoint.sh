#!/usr/bin/env bash

# exit on error
set -e

_term() {
  echo "`date +%F\ %T` ########################################################### Caught SIGTERM signal, stopping!"
  if [ $SERVER_MODE = "dual" ]; then
    echo "`date +%F\ %T` Shutting down slave"
    /home/jboss/slave/bin/artemis stop
  fi
  echo "`date +%F\ %T` Shutting down master"
  /home/jboss/master/bin/artemis stop & wait
  echo "`date +%F\ %T` Master down"

  exit 0
}

trap _term SIGTERM

# debugging of launch.sh script below
# export SCRIPT_DEBUG="true"

# Setting "ARTEMIS_MODE" to something different from "dual" makes the container only start one instance
export SERVER_MODE=${ARTEMIS_MODE:-"dual"}

# turn off specialized acceptors, we use the combined acceptor for all protocols
export TURN_OFF="--no-amqp-acceptor --no-hornetq-acceptor --no-mqtt-acceptor --no-stomp-acceptor"

# The following injects "our" logging.properties file into the created container.
# The only difference is that we add a "[master]" or "[slave]" into each and every line logged
export LOGGING_PROPERTIES=`cat /logging.properties`

# Prometheus - exposed on http://localhost:8161/metrics
export AMQ_ENABLE_METRICS_PLUGIN=true

# add graceful shutdown to broker.xml - 5000 millis timeout
export AMQ_ENABLE_GRACEFUL_SHUTDOWN=true

# Setting to clustered, normally this only have the values true/false, but we need to not change the default cluster
# broadcast and discovery group - we are running 2 instances in same container to have an independent data backup.
# any value not true and false will do
# The value is used in the script "launch.sh" - the original from Red Hat (/opt/amq/bin/launch.sh) is copied to "launch.sh.redhat"
# Please compare if needed
export AMQ_CLUSTERED=not_true_and_false

####################################################################### MASTER #########################################
# Start a master AMQ broker. It handles all request from outside
# running the container should supply a data directory
export AMQ_DATA_DIR=/data
export AMQ_NAME=master

if [ $SERVER_MODE = "dual" ]; then
  export AMQ_EXTRA_ARGS="--replicated $TURN_OFF"
else
  export AMQ_EXTRA_ARGS="$TURN_OFF"
  export AMQ_CLUSTERED=false
fi

/launch.sh &
# If debugging, replace the line above with the following 2 lines
# /launch.sh nostart >& /tmp/master_launch
# /home/jboss/master/bin/artemis run &
pid1=$!
echo "$pid1" > /tmp/$AMQ_NAME.pid
mkdir -p $AMQ_DATA_DIR/artemis_timestamp
touch $AMQ_DATA_DIR/artemis_timestamp/`date +"%FT%T"`_$AMQ_NAME

####################################################################### SLAVE ##########################################
if [ $SERVER_MODE = "dual" ]; then
  # Start a slave AMQ broker. Slave is passive, and is only there to have an independent data directory
  # running the container should supply a backup directory
  export AMQ_DATA_DIR=/backup
  export AMQ_NAME=slave
  export AMQ_EXTRA_ARGS="--replicated --slave --port-offset 1000 $TURN_OFF"

  /launch.sh &
  # If debugging, replace the line above with the following 2 lines
  # /launch.sh nostart >& /tmp/slave_launch
  # /home/jboss/slave/bin/artemis run &
  pid2=$!
  echo "$pid2" > /tmp/$AMQ_NAME.pid
  mkdir -p $AMQ_DATA_DIR/artemis_timestamp
  touch $AMQ_DATA_DIR/artemis_timestamp/`date +"%FT%T"`_$AMQ_NAME
fi

####################################################################### WAIT ###########################################
# wait forever - have signal handler do the exit
tail -f /dev/null & wait

echo "`date +%F\ %T` docker-entrypoint.sh exiting!"
exit 0
