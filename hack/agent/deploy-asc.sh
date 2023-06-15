#!/bin/bash

function deployAgentServiceConfig() {

    if [[ "${1}" == "" ]];then
        echo "I need an OCP Version"
        exit 1
    fi

    OCP_VERSION="${1}"
    DB_VOLUME_SIZE="10Gi"
    FS_VOLUME_SIZE="10Gi"
    OCP_MAJMIN=${OCP_VERSION%.*}
    ARCH=$(oc get node -o jsonpath={.status.nodeInfo.architecture} kind-control-plane)
    OCP_RELEASE_VERSION=$(curl -s https://mirror.openshift.com/pub/openshift-v4/${ARCH}/clients/ocp/${OCP_VERSION}/release.txt | awk '/machine-os / { print $2 }')
    ISO_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${OCP_MAJMIN}/${OCP_VERSION}/rhcos-${OCP_VERSION}-${ARCH}-live.${ARCH}.iso"
    ROOT_FS_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${OCP_MAJMIN}/${OCP_VERSION}/rhcos-${OCP_VERSION}-${ARCH}-live-rootfs.${ARCH}.img"

envsubst <<"EOF" | oc apply -f -
apiVersion: agent-install.openshift.io/v1beta1
kind: AgentServiceConfig
metadata:
    name: agent
    namespace: assisted-installer
spec:
    databaseStorage:
        accessModes:
        - ReadWriteOnce
        resources:
            requests:
                storage: ${DB_VOLUME_SIZE}
    filesystemStorage:
        accessModes:
        - ReadWriteOnce
        resources:
            requests:
                storage: ${FS_VOLUME_SIZE}
    osImages:
        - openshiftVersion: "${OCP_VERSION}"
          version: "${OCP_RELEASE_VERSION}"
          url: "${ISO_URL}"
          rootFSUrl: "${ROOT_FS_URL}"
          cpuArchitecture: "${ARCH}"
EOF

}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd )

deployAgentServiceConfig ${OCP_VERSION:-4.13.0}