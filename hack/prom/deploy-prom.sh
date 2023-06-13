function validateBin() {
    if [[ -z ${1} ]]; then
        echo "give me a binary to validate"
    fi

    BIN=${1}
    which -s ${BIN}
    if [[ $? != 0 ]]; then
        echo "${BIN} not available in $PATH, please download the binary and put it in the PATH"
        exit 1
    fi
}

function deployProm() {
    KPROM="/tmp/k-prom"
    mkdir -p ${KPROM}
    echo "Downloading Prometheus..."
    git clone https://github.com/prometheus-operator/kube-prometheus.git ${KPROM}
    cd ${KPROM}
    clear

    echo
    echo
    echo "K8s Environment: "
    echo "=================="
    echo "Kubeconfig: ${KUBECONFIG}"
    echo "Config:"
    kubectl config view --minify=true
    echo "=================="
    echo
    echo "Please, press enter to deploy Prometheus, make sure the destination is right"
    read
    ./developer-workspace/common/deploy-kube-prometheus.sh
    if [[ $? != 0 ]]; then
        echo "Error installing Prometheus. Exiting..."
        exit 1
    fi

    cd ${SCRIPT_DIR}
    rm -rf ${KPROM}
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd )
validateBin kubectl
validateBin git
deployProm
echo "Waiting for Prom deployment to finish"
kubectl wait --for=condition=Ready pods --all --all-namespaces
