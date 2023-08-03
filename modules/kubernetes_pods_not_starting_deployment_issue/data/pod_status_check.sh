bash
#!/bin/bash

# Set the deployment name and namespace
DEPLOYMENT_NAME=${DEPLOYMENT_NAME}
NAMESPACE=${NAMESPACE}

# Get the desired number of pods from the deployment configuration
DESIRED_PODS=$(kubectl get deployment ${DEPLOYMENT_NAME} -n ${NAMESPACE} -o=jsonpath='{.spec.replicas}')

# Get the current number of pods
CURRENT_PODS=$(kubectl get deployment ${DEPLOYMENT_NAME} -n ${NAMESPACE} -o=jsonpath='{.status.availableReplicas}')

# Compare the desired and current number of pods
if [[ ${DESIRED_PODS} -eq ${CURRENT_PODS} ]]; then
  echo "Deployment ${DEPLOYMENT_NAME} is running the desired number of pods."
else
  echo "Deployment ${DEPLOYMENT_NAME} is not running the desired number of pods."
fi