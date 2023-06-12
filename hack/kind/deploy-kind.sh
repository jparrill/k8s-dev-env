function validateBin() {
    if [[ -z ${1} ]]; then
        echo "give me a binary to validate"
    fi

    BIN=${1}
    which ${BIN}
    if [[ $? != 0 ]]; then
        echo "${BIN} not available in $PATH, please download the binary and put it in the PATH"
        exit 1
    fi
}

function installKind() {
    which kind
    if [[ $? != 0 ]]; then
        echo 'kind not available in $PATH'
        echo "Downloading Kind..."
        go install sigs.k8s.io/kind@v0.19.0
        export PATH=${PATH}:$(go env GOPATH)/bin
    fi
}

function deployCluster() {
    kind create cluster --config ${SCRIPT_DIR}/config.yaml
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
installKind
validateBin kubectl
deployCluster
echo "Waiting for Cluster deployment to finish"
kubectl wait --for=condition=Ready pods --all --all-namespaces
