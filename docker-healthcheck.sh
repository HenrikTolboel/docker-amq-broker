#!/usr/bin/env bash

# exit on error
set -e

exit_when_non_zero () {
  if [[ $1 != 0 ]]; then
    echo "Bad exit code: $1"
    exit 1
  fi
  echo "OK"
}

check_for_process () {
  SERVICE=$1
  if pgrep "$SERVICE" >/dev/null
  then
    echo "$SERVICE is running"
  else
    exit 1
  fi
}

check_for_java_program () {
  PROGRAM=$1
  if pgrep -a "java" | grep "$PROGRAM" >/dev/null
  then
    echo "java program $PROGRAM is running"
  else
    exit 1
  fi
}

exit_if_pattern_in_file() {
  Pattern=$1
  File=$2

  if grep $Pattern $File > /dev/null
  then
    echo "pattern '$Pattern' in '$File' - exiting, unhealthy!"
    exit 1
  fi
}

# Exit codes from docker healthcheck
# 0: success - the container is healthy and ready for use
# 1: unhealthy - the container is not working correctly
# 2: reserved - do not use this exit code

# Setting "ARTEMIS_MODE" to something different from "dual" makes the container only start one instance
SERVER_MODE=${ARTEMIS_MODE:-"dual"}

# It has been seen that the calculations results in negative value - artemis won't run
exit_if_pattern_in_file "<journal-buffer-timeout>-" /home/jboss/master/etc/broker.xml
if [ $SERVER_MODE = "dual" ]; then
  exit_if_pattern_in_file "<journal-buffer-timeout>-" /home/jboss/slave/etc/broker.xml
fi

check_for_process "java"
check_for_java_program "Ddata.dir=/data"

if [ $SERVER_MODE = "dual" ]; then
  check_for_java_program "Ddata.dir=/backup"
fi

export AMQ_NAME=master
/opt/amq/bin/readinessProbe.sh
exit_when_non_zero $?

#if [ $SERVER_MODE = "dual" ]; then
  # check that the slave is "ready" readinessProbe does not work here...
#fi

echo "HEALTHY"
exit 0
