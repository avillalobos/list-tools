IMAGE_NAME = lsst_cl_cp_dhcp

CONTAINER_LIST := $(shell docker ps -a -q --filter ancestor="${IMAGE_NAME}:latest")

build:
	cd etc/dhcp ; ln -sf dhcpd.conf.standalone dhcpd.conf ; cd -
	docker build -t ${IMAGE_NAME} -f LSST_dhcp_Dockerfile .	

build_master:
	cd etc/dhcp ; ln -sf dhcpd.conf.master dhcpd.conf ; cd -
	docker build -t ${IMAGE_NAME} -f LSST_dhcp_Dockerfile .	

build_slave:
	cd etc/dhcp ; ln -sf dhcpd.conf.slave dhcpd.conf ; cd -
	docker build -t ${IMAGE_NAME} -f LSST_dhcp_Dockerfile .	
clean:
	@for container in ${CONTAINER_LIST}; do\
		echo Deleting container id: $$container ;\
		docker container stop $$container ;\
		docker container rm $$container ;\
	done

delete:
	docker rmi ${IMAGE_NAME}


run:
	docker run -p 139.229.137.250:67:67/udp \
		--cap-add SYS_ADMIN \
		--net=host \
		--name dhcp_server \
		-v ${PWD}/var/lib/dhcpd:/var/lib/dhcpd \
		-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
		-d ${IMAGE_NAME}

all: clean delete build run
