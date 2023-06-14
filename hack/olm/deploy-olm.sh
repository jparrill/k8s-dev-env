#!/usr/bin/env bash
function deployCS() {
    CSFOLDER=${SCRIPT_DIR}/catalogSources
    CSOUTFOLDER="/tmp/olm/cs"
    PSNAME="pull-secret"
    mkdir -p ${CSOUTFOLDER}
    cd ${CSFOLDER}

    if [[ ! -z ${PULL_SECRET} ]];then
        kubectl create secret generic ${PSNAME} -n olm --from-file=.dockerconfigjson=${PULL_SECRET} --type=kubernetes.io/dockerconfigjson -o yaml --dry-run=client | kubectl apply -f -
        ADD_SECRET="true"

        for cs in certified-operators-cs.yaml community-operators-cs.yaml rh-marketplace-cs.yaml rh-operators-cs.yaml; do
            envsubst < ${cs} > ${CSOUTFOLDER}/${cs}
            if [[ ${ADD_SECRET} == "true" ]];then
                echo "  secrets:" >> ${CSOUTFOLDER}/${cs}
                echo "     - ${PSNAME}" >> ${CSOUTFOLDER}/${cs}
            fi
            oc apply -f ${CSOUTFOLDER}/${cs}
        done
    fi
}

function deployOLM() {
    default_base_url=https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/

    if [[ ${#@} -lt 1 || ${#@} -gt 2 ]]; then
        echo "Usage: $0 version [base_url]"
        echo "* version: the github release version"
        echo "* base_url: the github base URL (Default: $default_base_url)"
        exit 1
    fi

    if kubectl get deployment olm-operator -n openshift-operator-lifecycle-manager -o=jsonpath='{.spec}' > /dev/null 2>&1; then
        echo "OLM is already installed in a different configuration. This is common if you are not running a vanilla Kubernetes cluster. Exiting..."
        exit 1
    fi

    release="${1}"
    base_url="${2:-${default_base_url}}"
    url="${base_url}/${release}/deploy/upstream/quickstart/"
    namespace=olm

    kubectl apply -f "${url}/crds.yaml"
    kubectl wait --for=condition=Established -f "${url}/crds.yaml"
    kubectl apply -f "${url}/olm.yaml"

    # wait for deployments to be ready
    kubectl rollout status -w deployment/olm-operator --namespace="${namespace}"
    kubectl rollout status -w deployment/catalog-operator --namespace="${namespace}"

    retries=30
    until [[ $retries == 0 ]]; do
        new_csv_phase=$(kubectl get csv -n "${namespace}" packageserver -o jsonpath='{.status.phase}' 2>/dev/null || echo "Waiting for CSV to appear")
        if [[ $new_csv_phase != "$csv_phase" ]]; then
            csv_phase=$new_csv_phase
            echo "Package server phase: $csv_phase"
        fi
        if [[ "$new_csv_phase" == "Succeeded" ]]; then
    	break
        fi
        sleep 10
        retries=$((retries - 1))
    done

    if [ $retries == 0 ]; then
        echo "CSV \"packageserver\" failed to reach phase succeeded"
        exit 1
    fi

    kubectl rollout status -w deployment/packageserver --namespace="${namespace}"

}

if [[ ${#@} -lt 1 || ${#@} -gt 3 ]]; then
        echo "Usage: $0 olmVersion catalogSourceVersion"
        echo "* olmVersion: the github release version"
        echo "* catalogSourceVersion: OCP Registry Version to grab images from"
        exit 1
    fi

export OLMVERSION=${1}
export CSVERSION=${2}
export PULL_SECRET=${3}
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd )

##deployOLM ${OLMVERSION}
deployCS ${CSVERSION} ${PULL_SECRET}