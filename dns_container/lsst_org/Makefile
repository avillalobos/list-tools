IMAGE_BASENAME = lsst_org



CONTAINER_BASENAME = lsst_org


###########################################################################################
# COMMON SECTION

#TODO reserved to be used to build the all four containers (Master, Slave and Caching servers)

clean: clean_master clean_slave clean_cache

delete: delete_master delete_slave delete_cache

build: build_master build_slave build_cache

run: run_master run_slave run_cache

all: all_master all_slave all_cache

todo:
	@grep -E --color -Rn "\s*#\s*TODO" ./

###########################################################################################
# MASTER SECTION

MASTER_SUFFIX = master_dns

CONTAINER_LIST_MASTER := $(shell docker ps -a -q --filter ancestor="${IMAGE_BASENAME}_${MASTER_SUFFIX}:latest")

clean_master:
	@for container in ${CONTAINER_LIST_MASTER}; do\
		echo Deleting container id: $$container ;\
		docker container stop $$container ;\
		docker container rm $$container ;\
	done

delete_master:
	docker rmi ${IMAGE_BASENAME}_${MASTER_SUFFIX}


build_master:
	docker build -t ${IMAGE_BASENAME}_${MASTER_SUFFIX} -f dockerfiles/${IMAGE_BASENAME}_${MASTER_SUFFIX}_Dockerfile .

#TODO Modify the IP to match the production IP and expose the right ports
#TODO Add named.conf as volume for debugging
run_master:
	docker run --ip 172.24.1.250 \
		--net dns_internal_network \
		--cap-add SYS_ADMIN \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-v ${PWD}/var/named/lsst.org.zone:/var/named/lsst.org.zone \
		--name ${CONTAINER_BASENAME}_${MASTER_SUFFIX} \
		-d ${IMAGE_BASENAME}_${MASTER_SUFFIX}

exec_master:
	docker exec -it ${CONTAINER_BASENAME}_${MASTER_SUFFIX} /bin/bash




all_master: clean_master delete_master build_master run_master

###########################################################################################
# SLAVE SECTION

SLAVE_SUFFIX = slave_dns

CONTAINER_LIST_SLAVE := $(shell docker ps -a -q --filter ancestor="${IMAGE_BASENAME}_${SLAVE_SUFFIX}:latest")

clean_slave:
	@for container in ${CONTAINER_LIST_SLAVE}; do\
		echo Deleting container id: $$container ;\
		docker container stop $$container ;\
		docker container rm $$container ;\
	done

delete_slave:
	docker rmi ${IMAGE_BASENAME}_${SLAVE_SUFFIX}


build_slave:
	docker build -t ${IMAGE_BASENAME}_${SLAVE_SUFFIX} -f dockerfiles/${IMAGE_BASENAME}_${SLAVE_SUFFIX}_Dockerfile .
	@echo build slave: soon...

#TODO Modify the IP to match the production IP and expose the right ports
#TODO Add named.conf as volume for debugging
run_slave:
	docker run --ip 172.24.1.251 \
		--net dns_internal_network \
		--cap-add SYS_ADMIN \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-v ${PWD}/var/named/lsst.org.zone:/var/named/lsst.org.zone \
		--name ${CONTAINER_BASENAME}_${SLAVE_SUFFIX} \
		-d ${IMAGE_BASENAME}_${SLAVE_SUFFIX}

exec_slave:
	docker exec -it ${CONTAINER_BASENAME}_${SLAVE_SUFFIX} /bin/bash

all_slave: clean_slave delete_slave build_slave run_slave


###########################################################################################
# CACHE SECTION

CACHE_SUFFIX = cache_dns

CONTAINER_LIST_CACHE := $(shell docker ps -a -q --filter ancestor="${IMAGE_BASENAME}_${CACHE_SUFFIX}:latest")

clean_cache:
	@for container in ${CONTAINER_LIST_CACHE}; do \
		echo Deleting container id: $$container ;\
		docker container stop $$container ;\
		docker container rm $$container ;\
	done

delete_cache:
	docker rmi ${IMAGE_BASENAME}_${CACHE_SUFFIX}


build_cache:
	docker build -t ${IMAGE_BASENAME}_${CACHE_SUFFIX} -f dockerfiles/${IMAGE_BASENAME}_${CACHE_SUFFIX}_Dockerfile .
	@echo build slave: soon...

#TODO Modify the IP to match the production IP and expose the right ports
#TODO Add named.conf as volume for debugging
run_cache:
	docker run --ip 172.24.1.252 \
		--net dns_internal_network \
		--cap-add SYS_ADMIN \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-v ${PWD}/etc/resolv.conf:/etc/resolv.conf \
		--name ${CONTAINER_BASENAME}_${CACHE_SUFFIX}_1 \
		-d ${IMAGE_BASENAME}_${CACHE_SUFFIX}
	docker run --ip 172.24.1.253 \
		--net dns_internal_network \
		--cap-add SYS_ADMIN \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-v ${PWD}/etc/resolv.conf:/etc/resolv.conf \
		--name ${CONTAINER_BASENAME}_${CACHE_SUFFIX}_2 \
		-d ${IMAGE_BASENAME}_${CACHE_SUFFIX}

exec_cache:
	docker exec -it ${CONTAINER_BASENAME}_${SLAVE_SUFFIX} /bin/bash

all_cache: clean_cache delete_cache build_cache run_cache
