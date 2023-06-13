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

function createCert() {
    TLSFOLD=/tmp/hypershift/certs
    mkdir -p ${TLSFOLD}
    cd ${TLSFOLD}

    DOMAIN=${1}

    if [[ ! -f ca.key ]];then
        openssl genrsa -out ca.key 4096
        openssl req -x509 -new -nodes -days 365 -key ca.key -out ca.crt -subj "/CN=${DOMAIN}"
    fi

    export CA=${TLSFOLD}/ca.crt
    export KEY=${TLSFOLD}/ca.key
    cd ${SCRIPT_DIR}

    ## Openshift-ca-bundle
    kubectl create configmap -n hypershift openshift-config-managed-trusted-ca-bundle --from-file=ca-bundle.crt=${CA} -o yaml --dry-run=client | kubectl apply -f -
    ## manager-serving-cert
    kubectl create secret -n hypershift tls manager-serving-cert --key ${KEY} --cert ${CA} -o yaml --dry-run=client | kubectl apply -f -
}

function deployHypershift() {

    echo
    echo
    echo "K8s Environemnt:"
    echo "=================="
    echo "Kubeconfig: ${KUBECONFIG}"
    echo "Config:"
    kubectl config view --minify=true

    echo "Please, press enter to deploy hypershift, make sure the destination is right"
    if [[ "${CHECK}" == "true" ]];then
        read
    fi

    HYPERFOLD=/tmp/hypershift/repo
    mkdir -p ${HYPERFOLD}
    git clone https://github.com/openshift/hypershift.git ${HYPERFOLD}
    cd ${HYPERFOLD}

    ## Make sure you have golang 1.19 or 1.20, 1.21 is not supported yet
    make build
    ${HYPERFOLD}/bin/hypershift install --development
    sleep 5
    createCert ${1}
    oc scale deployment/operator -n hypershift --replicas=1
    oc wait pod -n hypershift -l app=operator --for condition=Ready --timeout=120s
    cd ${SCRIPT_DIR}

}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
validateBin openssl

if [[ "${1}" == "" ]];then
    echo "I need a domain to generate the certificate for Hypershift webhook"
    exit 1
fi

deployHypershift ${1}
sleep 5
kubectl wait --for=condition=Ready pods --all --all-namespaces
