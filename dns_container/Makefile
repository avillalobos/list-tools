IMAGE_NAME = lsst_cl_cp_dhcp

CONTAINER_LIST := $(shell docker ps -a -q --filter ancestor="${IMAGE_NAME}:latest")

#TODO: This is reserved to build all the targets below this level, to be deployed at the end

clean: clean_lsst_org clean_cl_lsst_org clean_ls_cl_lsst_org

build: build_lsst_org build_cl_lsst_org build_ls_cl_lsst_org

run: run_lsst_org run_cl_lsst_org run_ls_cl_lsst_org

all: all_lsst_org all_cl_lsst_org all_ls_cl_lsst_org

todo:
	@grep -E --color -Rn "\s*#\s*TODO" ./

####
# LSST.ORG Section
####

clean_lsst_org:
	cd lsst_org && ${MAKE} clean

delete_lsst_org:
	cd lsst_org && ${MAKE} delete

build_lsst_org:
	cd lsst_org && ${MAKE} build

run_lsst_org:
	cd lsst_org && ${MAKE} run

exec_lsst_org:
	cd lsst_org && ${MAKE} exec

all_lsst_org: clean_lsst_org delete_lsst_org build_lsst_org run_lsst_org


####
# CL.LSST.ORG Section
####
clean_cl_lsst_org:
	cd cl_lsst_org && ${MAKE} clean

delete_cl_lsst_org:
	cd cl_lsst_org && ${MAKE} delete

build_cl_lsst_org:
	cd cl_lsst_org && ${MAKE} build

run_cl_lsst_org:
	cd cl_lsst_org && ${MAKE} run

exec_cl_lsst_org:
	cd cl_lsst_org && ${MAKE} exec

all_cl_lsst_org: clean_cl_lsst_org delete_cl_lsst_org build_cl_lsst_org run_cl_lsst_org

####
# LS.CL.LSST.ORG Section
####
clean_ls_cl_lsst_org:
	cd ls_cl_lsst_org && ${MAKE} clean

delete_ls_cl_lsst_org:
	cd ls_cl_lsst_org && ${MAKE} delete

build_ls_cl_lsst_org:
	cd ls_cl_lsst_org && ${MAKE} build

run_ls_cl_lsst_org:
	cd ls_cl_lsst_org && ${MAKE} run

exec_ls_cl_lsst_org:
	cd ls_cl_lsst_org && ${MAKE} exec

all_ls_cl_lsst_org: clean_ls_cl_lsst_org delete_ls_cl_lsst_org build_ls_cl_lsst_org run_ls_cl_lsst_org
