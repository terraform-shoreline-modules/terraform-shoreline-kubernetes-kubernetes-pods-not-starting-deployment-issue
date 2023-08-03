
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes pods not starting - Deployment issue
---

This incident type involves an issue with Kubernetes deployments where the expected number of pods to run is not matching the actual number of pods running. This can lead to alerts being triggered and potential disruptions in the system.

### Parameters
```shell
# Environment Variables
export DEPLOYMENT_NAME="PLACEHOLDER"
export POD_NAME="PLACEHOLDER"
export YOUR_NAMESPACE="PLACEHOLDER"
export YOUR_DEPLOYMENT="PLACEHOLDER"
export DESIRED_NUMBER_OF_PODS="PLACEHOLDER"
```

## Debug

### List all deployments in the cluster
```shell
kubectl get deployments
```

### Check the status of each deployment
```shell
kubectl rollout status deployment/${DEPLOYMENT_NAME}
```

### Get the number of desired replicas for each deployment
```shell
kubectl get deployment ${DEPLOYMENT_NAME} -o=jsonpath='{.spec.replicas}'
```

### Check the logs of a specific pod
```shell
kubectl logs ${POD_NAME}
```

### Get the number of available replicas for each deployment
```shell
kubectl get deployment ${DEPLOYMENT_NAME} -o=jsonpath='{.status.availableReplicas}'
```

### Check the events related to a specific deployment
```shell
kubectl describe deployment ${DEPLOYMENT_NAME}
```

### Resource constraints: If there are not enough resources available in the cluster to create the desired number of pods, Kubernetes may not be able to start all of them.
```shell
bash
#!/bin/bash

# Define variables
NAMESPACE="${YOUR_NAMESPACE}"
DEPLOYMENT="${YOUR_DEPLOYMENT}"
POD_COUNT="${DESIRED_NUMBER_OF_PODS}"

# Check CPU and memory usage in the namespace
CPU_USAGE=$(kubectl top pods -n $NAMESPACE | awk '{sum += $2} END {print sum}')
MEMORY_USAGE=$(kubectl top pods -n $NAMESPACE | awk '{sum += $3} END {print sum}')

# Check available resources in the cluster
CPU_LIMIT=$(kubectl describe node | grep "cpu:" | awk '{sum += $3} END {print sum}')
MEMORY_LIMIT=$(kubectl describe node | grep "memory:" | awk '{sum += $3} END {print sum}')

# Calculate available resources
CPU_AVAILABLE=$(($CPU_LIMIT - $CPU_USAGE))
MEMORY_AVAILABLE=$(($MEMORY_LIMIT - $MEMORY_USAGE))

# Check if available resources are sufficient for desired number of pods
POD_CPU=$(kubectl describe deployment $DEPLOYMENT -n $NAMESPACE | grep "cpu:" | awk '{print $2}')
POD_MEMORY=$(kubectl describe deployment $DEPLOYMENT -n $NAMESPACE | grep "memory:" | awk '{print $2}')
POD_CPU_TOTAL=$(($POD_CPU * $POD_COUNT))
POD_MEMORY_TOTAL=$(((${POD_MEMORY%Mi} * $POD_COUNT) / 1024))

if [[ $CPU_AVAILABLE -lt $POD_CPU_TOTAL ]]; then
    echo "Not enough CPU available"
elif [[ $MEMORY_AVAILABLE -lt $POD_MEMORY_TOTAL ]]; then
    echo "Not enough memory available"
else
    echo "Resources are sufficient"
fi

```

### Software bugs: There may be bugs in Kubernetes or other software components that are preventing pods from starting up as expected.
```shell

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

```
## Repair

### Check the deployment configuration to ensure that the desired number of pods is correctly set.
```shell
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

```

### Check for any resource constraints that may be limiting the creation of new pods and adjust as necessary.
```shell

#!/bin/bash

# Get the current resource usage for the cluster
kubectl top nodes

# Check for any resource constraints that may be causing issues
kubectl describe nodes | grep -i capacity

# Check for any pods that are in a pending state
kubectl get pods --all-namespaces | grep -i pending

# Check for any pods that have failed to start
kubectl get pods --all-namespaces | grep -i error

# Check the event log for any relevant error messages
kubectl get events --all-namespaces | grep -i error

```