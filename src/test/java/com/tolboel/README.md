# Test Artemis server

The 3 programs in this directory together with the docker image and starting and stopping the
JMS server, describes that the various scenarios work as intended.

The 3 programs are very simple write and / or read messages to / from the JMS server.


## Scenario 1 - write and read

The following steps are included:

- create volumes
- start JMS server
- run the testArtemisWriteRead program
- see that messages are read and written to standard out

code:

```bash
docker volume create artemis_data
docker volume create artemis_backup

docker run -d --name artemis \
   -p 8161:8161 \
   -p 61616:61616 \
   -v artemis_data:/data \
   -v artemis_backup:/backup \
   -e AMQ_USER=admin \
   -e AMQ_PASSWORD=admin \
   artemis:latest
```

run the testArtemisWriteRead program.

## Scenario 2 - write, restart, and read

This scenario tests that messages are persisted across sessions

The following steps are included:

- create volumes
- start JMS server
- run the testArtemisWrite program
- restart JMS server
- see that messages are read and written to standard out

code:

```bash
docker volume rm artemis_data artemis_backup
docker volume create artemis_data
docker volume create artemis_backup

docker run -d --name artemis \
   -p 8161:8161 \
   -p 61616:61616 \
   -v artemis_data:/data \
   -v artemis_backup:/backup \
   -e AMQ_USER=admin \
   -e AMQ_PASSWORD=admin \
   artemis:latest
```

run the testArtemisWrite program.

run the following:

```bash
docker stop artemis
docker rm artemis

docker run -d --name artemis \
   -p 8161:8161 \
   -p 61616:61616 \
   -v artemis_data:/data \
   -v artemis_backup:/backup \
   -e AMQ_USER=admin \
   -e AMQ_PASSWORD=admin \
   artemis:latest
```

run the program testArtemisRead program, and see that messages are read and written to standard out.

## Scenario 3 - write, stop, and restart on backup

This scenario tests that the backup of messages works as intended.

The following steps are included:

- create volumes
- start JMS server
- run the testArtemisWrite program
- stop JMS server
- start JMS with the backup volume as master
- see that messages are read and written to standard out

code:

```bash
docker volume rm artemis_data artemis_backup
docker volume create artemis_data
docker volume create artemis_backup

docker run -d --name artemis \
   -p 8161:8161 \
   -p 61616:61616 \
   -v artemis_data:/data \
   -v artemis_backup:/backup \
   -e AMQ_USER=admin \
   -e AMQ_PASSWORD=admin \
   artemis:latest
```

run the testArtemisWrite program.

run the following:

```bash
docker stop artemis
docker rm artemis

docker run -d --name artemis \
   -p 8161:8161 \
   -p 61616:61616 \
   -v artemis_backup:/data \
   -e ARTEMIS_MODE=single \
   -e AMQ_USER=admin \
   -e AMQ_PASSWORD=admin \
   artemis:latest
```

run the program testArtemisRead program, and see that messages are read and written to standard out.
