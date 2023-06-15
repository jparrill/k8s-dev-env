#!/usr/bin/env bash

function validateBin() {
    if [[ -z ${1} ]]; then
        echo "give me a binary to validate"
    fi

    BIN=${1}
    which -s ${BIN}
    if [[ $? != 0 ]]; then
         echo "${BIN} not available in $PATH, please download the binary and put it in the PATH"
         echo "URL: https://github.com/karmab/tasty/releases"
        exit 1
    fi
}

function deployHive() {
    tasty install assisted-service-operator --sourcens ${CSNS}
}

function deployAgent() {
    tasty install hive-operator --sourcens ${CSNS}

}

CSNS="olm"

validateBin tasty
deployHive
deployAgent
seelp 10
kubectl wait --for=condition=Ready pods --all --all-namespaces