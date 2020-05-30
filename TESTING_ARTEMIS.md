# Testing Artemis container
We can test the artemis container by building, starting, adding messages, retrieving messages, and moving to backup 
directory as source data.

In the following a description of such a test is described (and conducted).

## Test scenario
We have a container add messages to a TEST queue, retrieve messages.
See that we can restart and retrieve saved messages.

Test that we can move to running from the backup data, and are able to add a new set of backup data.

We will make a scenario with 3 volumes, and show that we can get data through all 3, by moving through
restarting the container with new volumes.

That is we start out with a container running with v1 and v2, and show that we can move along to a container
running with volume v3.

We will show that this works, both with ```docker volumes``` and with host (SAN) mounted directories.

All the commands to be executed are placed inside the ```Makefile```, if You do not have make, You need to look up the 
commands actually being executed from the ```Makefile``` and type them yourself.

## Scenario 1 - docker volumes

### Prepare

Run the following commands, in order to build and prepare the container and volumes:

```bash
make build # build artemis:latest container
make volume_create # create docker volumes v1, v2, v3
```

### run tests

Run the following commands:

```bash
make run_1_2 # start a container with volumes v1 (master) and v2 (backup)

make health # check that the container is healthy :-)

make produce # add 1000 messages to the queue TEST
make produce # add 1000 messages to the queue TEST

make stat # see that the queue TEST contains 2000 messages
make consume # read 1000 messages from TEST

make stat # see we still have 1000 messages on TEST

make stop # container stops

make run_1_2 # start the container again

make stat # see we still have 1000 messages on TEST

```

We will now change to a scenario, where we have to switch to the backup volume, for some reason
the container stopped.

Run the following commands:

```bash
make stop # the container stops

make run_2 # start a container with only the v2 volume is started (no backup)

make stat # see we still have 1000 messages on TEST

make produce # add 1000 messages to the queue TEST
make produce # add 1000 messages to the queue TEST

make stat # see that the queue TEST contains 3000 messages
make consume # read 1000 messages from TEST
make stat # see that the queue TEST contains 2000 messages
```

We will now change to a scenario, where we add a new backup volume v3.

Run the following commands:

```bash
make stop # the container stops

make run_2_3 # start a new container with volumes v2 (master) and v3 (backup)

make stat # see that the queue TEST contains 2000 messages

make consume # read 1000 messages from TEST
make stat # see that the queue TEST contains 1000 messages

make produce # add 1000 messages to the queue TEST
make produce # add 1000 messages to the queue TEST

make stat # see that the queue TEST contains 3000 messages

make stop # container stops

make run_2_3 # start the container again

make stat # see we still have 3000 messages on TEST
```

We will now change to a scenario, where we have to switch to the backup volume, for some reason
the container stopped.

Run the following commands:

```bash
make stop # the container stops

make run_3 # start a container with only the v3 volume is started (no backup)

make stat # see we still have 3000 messages on TEST

make produce # add 1000 messages to the queue TEST
make produce # add 1000 messages to the queue TEST

make stat # see that the queue TEST contains 5000 messages
make consume # read 1000 messages from TEST
make stat # see that the queue TEST contains 4000 messages
```

#### Exercise
add a volume v4, and bring the container up with that as backup...

## Scenario 2 - host mounted directories

### Prepare

Run the following commands, in order to build and prepare the container and volumes:

```bash
make stop # stop container if You left it running
make build # build artemis:latest container, it probably didn't change :-)
make dir # create directories vol1, vol2, vol3
```

### run tests
The scenarios here are the same as above for scenario 1. Everywhere where a ```run_*``` is executed, 
execute ```run_dir_*``` instead.

That is replace ```make run_1_2``` with ```make run_dir_1_2```, and so on.

See that the results are as above.

## Scenario 3 - test from java and camel
Accessing the artemis container subsystem from java and camel is demonstrated in the java test sub-project. 
Please refer to there as well.


