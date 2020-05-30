volume_create:
	docker volume create v1
	docker volume create v2
	docker volume create v3

volume_remove:
	docker volume rm v1 v2 v3

stop:
	docker stop artemis

run_1_2:
	docker run -d --rm --name artemis \
	    -p 8161:8161 -p 61616:61616 -p 9161:9161 \
	    -v v1:/data -v v2:/backup \
	    -e AMQ_USER=admin -e AMQ_PASSWORD=admin \
	    artemis:latest

run: run_1_2

run_2:
	docker run -d --rm --name artemis \
	    -p 8161:8161 -p 61616:61616 -p 9161:9161 \
	    -v v2:/data \
	    -e AMQ_USER=admin -e AMQ_PASSWORD=admin -e ARTEMIS_MODE=single \
	    artemis:latest

run_3:
	docker run -d --rm --name artemis \
	    -p 8161:8161 -p 61616:61616 -p 9161:9161 \
	    -v v3:/data \
	    -e AMQ_USER=admin -e AMQ_PASSWORD=admin -e ARTEMIS_MODE=single \
	    artemis:latest

run_2_3:
	docker run -d --rm --name artemis \
	    -p 8161:8161 -p 61616:61616 -p 9161:9161 \
	    -v v2:/data -v v3:/backup \
	    -e AMQ_USER=admin -e AMQ_PASSWORD=admin -e ARTEMIS_MODE=dual \
	    artemis:latest

build:
	docker build -t artemis:latest .

health:
	docker exec -it artemis /docker-healthcheck.sh

produce:
	docker exec -it artemis /produce.sh

consume:
	docker exec -it artemis /consume.sh

stat:
	docker exec -it artemis /stat.sh

bash:
	docker exec -it artemis bash

logs:
	docker logs -f artemis

forfra: volume_remove volume_create build run_1_2

dangling:
	docker rmi `docker images -f dangling=true -q`

dir:
	mkdir vol1 vol2 vol3
	sudo chown 185:0 vol1 vol2 vol3
	sudo chmod 777 vol1 vol2 vol3

rmdir:
	sudo rm -rf vol1 vol2 vol3

run_dir_1_2:
	docker run -d --rm --name artemis \
        -p 8161:8161 -p 61616:61616 -p 9161:9161 \
        -v ${PWD}/vol1:/data -v ${PWD}/vol2:/backup \
        -e AMQ_USER=admin -e AMQ_PASSWORD=admin \
        artemis:latest


run_dir: run_dir_1_2

run_dir_2:
	docker run -d --rm --name artemis \
	    -p 8161:8161 -p 61616:61616 -p 9161:9161 \
	    -v ${PWD}/vol2:/data \
	    -e AMQ_USER=admin -e AMQ_PASSWORD=admin -e ARTEMIS_MODE=single \
	    artemis:latest

run_dir_3:
	docker run -d --rm --name artemis \
	    -p 8161:8161 -p 61616:61616 -p 9161:9161 \
	    -v ${PWD}/vol3:/data \
	    -e AMQ_USER=admin -e AMQ_PASSWORD=admin -e ARTEMIS_MODE=single \
	    artemis:latest

run_dir_2_3:
	docker run -d --rm --name artemis \
	    -p 8161:8161 -p 61616:61616 -p 9161:9161 \
	    -v ${PWD}/vol2:/data -v ${PWD}/vol3:/backup \
	    -e AMQ_USER=admin -e AMQ_PASSWORD=admin -e ARTEMIS_MODE=dual \
	    artemis:latest
