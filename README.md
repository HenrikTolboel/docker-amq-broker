# Artemis Docker

The purpose of the Artemis docker image is to make a container for a Standalone
JMS server. Moving away from per customer servers, we need a central JMS server that can be used for 
all customers. 
The container is a single docker image exporting 2 sets of queue data for persistence - per decisions made also 
with operations.
 
The container is setup with prometheus metrics for surveillance.

As well the standard AMQ Broker console is exposed.

## The Image
The image is based on the Red Hat AMQ7 image currently version 7.5.

You can get the image (needing access to Red Hat)

```bash
docker login registry.redhat.io -u <Username - not e-mail> -p <password>
docker pull registry.redhat.io/amq7/amq-broker-lts-rhel7:7.5
docker tag registry.redhat.io/amq7/amq-broker-lts-rhel7:7.5 nexus3.nuc.local:9000/amq7/amq-broker-lts-rhel7:7.5
docker push nexus3.nuc.local:9000/amq7/amq-broker-lts-rhel7:7.5
```

### Build the image

To build the image, open a Terminal window, navigate to this folder and run:

```bash
docker build -t artemis:latest .
```

### Push the image to Nexus3

To push the newly created image to Nexus3, run:

```bash
docker tag artemis:latest nexus3.nuc.local:9000/artemis:latest
docker push nexus3.nuc.local:9000/artemis:latest
```

If you are required to login, then run:

```bash
docker login --username deploy --password <password> nexus3.nuc.local:9000
```

The password can be found elsewhere.

### Test the image

The easiest way to test the image is by running:

```bash
docker run -d --name artemis -p 8161:8161 -p 61616:61616 \
   -e AMQ_USER=admin -e AMQ_PASSWORD=admin \
   nexus3.nuc.local:9000/artemis:latest
```

This will start the container. Login to the container

```bash
docker exec -it artemis bash
<do your linux stuff>
exit
```
Open your browser on ```http://localhost:8161``` using the ```admin``` user. You can see queues in the admin console.


## The Container

When running a container from the artemis Docker image, the following volumes can be configured.

 Volume    | Description
 ----------|------------
 `/data`   | Data directory for master AMQ |
 `/backup` | Data directory for slave AMQ  |

Main AMQ broker parameters:

 Environment variable | Description
 ---------------------|------------
 `AMQ_USER`           | Specify the User for the AMQ brokers
 `AMQ_PASSWORD`       | Specify the User password for the AMQ brokers
 `ARTEMIS_MODE`       | If set to 'single' only one instance of AMQ broker is started 
 `JAVA_OPTS`          | Be careful out there, only valid values or the container won't start, certain values are not allowed. Specified values will be added to what RedHat actually sets up for JAVA_OPTS

Exposed AMQ broker ports:

 Port number | Description
 ------------|------------
 8161        | Master instance console port
 61616       | Master instance connector port
 9161        | Slave instance console port (normally not needed)
 62616       | Slave instance connector port (normally not needed)

### Docker Compose

An example of `docker-compose.yml` file, where we mount volumes for brokers.

```yml
version: '3.7'
services:
  artemis:
    image: ${DOCKER_IMAGE_NAME}
    restart: always
    ports:
      - "8161:8161"
      - "61616:61616"
      - "9161:9161"
      - "62616:62616"
    container_name: ${DOCKER_CONTAINER_NAME}
    logging:
      driver: "json-file"
      options:
        max-size: "${DOCKER_LOG_SIZE}"
    volumes:
      - data:/data
      - backup:/backup
    environment:
      - AMQ_USER=admin
      - AMQ_PASSWORD=admin
      # - JAVA_OPTS=-XX:+UnlockExperimentalVMOptions -XX:+BeCarefulHere
volumes:
  data:
  backup:
```

## Persistence of queues

As can be seen above, the container is dependent on having 2 data volumes for its persistence of data.
The directories (inside the container) ```/data``` and ```/backup```.
In test situations these can be used with docker volumes, but in production like environments needs real directories 
for security - docker volumes cannot be moved to other servers.

### creating docker volumes
Docker volumes can be created as part of a ```docker-compose.yml``` file (see above), or be created
with the ```docker volume``` command.

```bash
docker volume create artemis_data
docker volume create artemis_backup
```

#### Running artemis with 2 instances and 2 directories

The following command runs the artemis container with 2 mounted directories

```bash
docker run -d --name artemis \
   -p 8161:8161 \
   -p 61616:61616 \
   -v artemis_data:/data \
   -v artemis_backup:/backup \
   -e AMQ_USER=admin \
   -e AMQ_PASSWORD=admin \
   nexus3.nuc.local:9000/artemis:latest
```

#### Running artemis with 1 instances and backup directory only

The following command runs the artemis container with backup directory mounted as data.
This example demonstrates how the failover could be tested.

```bash
docker run -d --name artemis \
   -p 8161:8161 \
   -p 61616:61616 \
   -v artemis_backup:/data \
   -e ARTEMIS_MODE=single \
   -e AMQ_USER=admin \
   -e AMQ_PASSWORD=admin \
   nexus3.nuc.local:9000/artemis:latest
```

### Creating Production volumes
In production environments we should used mounted directories for data. Reason, docker volumes are not promised to 
be transportable to another server if a server breaks.

The 2 directories needed should be created on 2 different SAN systems.

The directories should be owned by the generating containers user - user id 185:185. 
That is (run as root)

```bash
cd /..../SAN1
mkdir data
chown 185:185 data

cd /..../SAN2
mkdir backup
chown 185:185 backup
```

#### Running artemis with 2 instances and 2 directories

The following command runs the artemis container with 2 mounted directories

```bash
docker run -d --name artemis \
   -p 8161:8161 \
   -p 61616:61616 \
   -v /..../SAN1/data:/data \
   -v /..../SAN2/backup:/backup \
   -e AMQ_USER=admin \
   -e AMQ_PASSWORD=admin \
   nexus3.nuc.local:9000/artemis:latest
```

#### Running artemis with 1 instances and backup directory only

The following command runs the artemis container with backup directory mounted as data.
This example demonstrates how the fail-over could be tested.

```bash
docker run -d --name artemis \
   -p 8161:8161 \
   -p 61616:61616 \
   -v /..../SAN2/backup:/data \
   -e ARTEMIS_MODE=single \
   -e AMQ_USER=admin \
   -e AMQ_PASSWORD=admin \
   nexus3.nuc.local:9000/artemis:latest
```

## Prometheus metrics
Prometheus metrics have been enabled: see the endpoint ```http://localhost:8161/metrics```
that exports the prometheus metrics.

## Testing artemis
A description of test scenarios to be found in the ```TESTING_ARTEMIS.md``` document.
