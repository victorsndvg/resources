#!/bin/bash

# Possible argument {up,down}

arg=$1
upload=${2:-"upload"}
echo "upload=$upload"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
ROOT_DIR=${SCRIPT_DIR}/../../../
JOB=hfm_benchmark_HL-dble
UPLOAD_DIR=${SCRIPT_DIR}/$upload
TOSCA=blueprint.yaml
LOCAL=local-blueprint-inputs.yaml
LOCAL_DIR=../../../../

if [ ! -f "${SCRIPT_DIR}/${LOCAL}" ]; then
    echo "${SCRIPT_DIR}/${LOCAL} does not exist! See doc or blueprint examples!"
    exit 1
fi

cd ${UPLOAD_DIR}

case $arg in
    "up" )
        cfy blueprints upload -b "${JOB}" "${TOSCA}"
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy deployments create -b "${JOB}" -i "${SCRIPT_DIR}/${LOCAL}" --skip-plugins-validation ${JOB}
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy executions start -d "${JOB}" install
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy executions start -d "${JOB}" run_jobs
        ;;

    "down" )
        echo "Uninstalling deployment ${JOB}..."
        cfy executions start -d "${JOB}" uninstall
        echo "Deleting deployment ${JOB}..."
        cfy deployments delete "${JOB}"
        echo "Deleting blueprint ${JOB}..."
        cfy blueprints delete "${JOB}"
        ;;
    *)
        echo "usage: $0 [option]"
        echo ""
        echo "options:"
        echo "      up     send to orchestrator"
        echo "    down     remove from orchestrator"
        echo ""
        ;;
esac
