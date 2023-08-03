
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