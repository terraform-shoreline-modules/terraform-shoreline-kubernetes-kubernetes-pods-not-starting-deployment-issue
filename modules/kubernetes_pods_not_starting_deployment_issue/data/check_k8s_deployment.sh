
#!/bin/bash

# Set variables
K8S_NAMESPACE=${NAMESPACE}
K8S_DEPLOYMENT=${DEPLOYMENT}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found"
    exit
fi

# Check if Kubernetes deployment exists
if ! kubectl get deployment $K8S_DEPLOYMENT -n $K8S_NAMESPACE &> /dev/null
then
    echo "Deployment $K8S_DEPLOYMENT not found in namespace $K8S_NAMESPACE"
    exit
fi

# Check if all pods are running
EXPECTED_REPLICAS=$(kubectl get deployment $K8S_DEPLOYMENT -n $K8S_NAMESPACE -o jsonpath="{.spec.replicas}")
CURRENT_REPLICAS=$(kubectl get deployment $K8S_DEPLOYMENT -n $K8S_NAMESPACE -o jsonpath="{.status.availableReplicas}")
if [[ $EXPECTED_REPLICAS != $CURRENT_REPLICAS ]]
then
    echo "Expected $EXPECTED_REPLICAS replicas but found $CURRENT_REPLICAS"
    exit
fi

# Check if there are any error events
ERROR_EVENTS=$(kubectl get events -n $K8S_NAMESPACE --sort-by='{.lastTimestamp}' --field-selector type!=Normal,involvedObject.kind=Deployment,involvedObject.name=$K8S_DEPLOYMENT -o json | jq '.items[] | {timestamp, message}')
if [[ $ERROR_EVENTS ]]
then
    echo "Found the following error events:"
    echo $ERROR_EVENTS
else
    echo "No error events found"
fi