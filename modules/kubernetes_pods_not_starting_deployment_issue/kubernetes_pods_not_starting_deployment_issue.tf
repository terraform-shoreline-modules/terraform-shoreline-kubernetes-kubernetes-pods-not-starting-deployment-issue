resource "shoreline_notebook" "kubernetes_pods_not_starting_deployment_issue" {
  name       = "kubernetes_pods_not_starting_deployment_issue"
  data       = file("${path.module}/data/kubernetes_pods_not_starting_deployment_issue.json")
  depends_on = [shoreline_action.invoke_sufficient_resources,shoreline_action.invoke_check_k8s_deployment,shoreline_action.invoke_pod_status_check,shoreline_action.invoke_cluster_resource_check]
}

resource "shoreline_file" "sufficient_resources" {
  name             = "sufficient_resources"
  input_file       = "${path.module}/data/sufficient_resources.sh"
  md5              = filemd5("${path.module}/data/sufficient_resources.sh")
  description      = "Resource constraints: If there are not enough resources available in the cluster to create the desired number of pods, Kubernetes may not be able to start all of them."
  destination_path = "/agent/scripts/sufficient_resources.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "check_k8s_deployment" {
  name             = "check_k8s_deployment"
  input_file       = "${path.module}/data/check_k8s_deployment.sh"
  md5              = filemd5("${path.module}/data/check_k8s_deployment.sh")
  description      = "Software bugs: There may be bugs in Kubernetes or other software components that are preventing pods from starting up as expected."
  destination_path = "/agent/scripts/check_k8s_deployment.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "pod_status_check" {
  name             = "pod_status_check"
  input_file       = "${path.module}/data/pod_status_check.sh"
  md5              = filemd5("${path.module}/data/pod_status_check.sh")
  description      = "Check the deployment configuration to ensure that the desired number of pods is correctly set."
  destination_path = "/agent/scripts/pod_status_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "cluster_resource_check" {
  name             = "cluster_resource_check"
  input_file       = "${path.module}/data/cluster_resource_check.sh"
  md5              = filemd5("${path.module}/data/cluster_resource_check.sh")
  description      = "Check for any resource constraints that may be limiting the creation of new pods and adjust as necessary."
  destination_path = "/agent/scripts/cluster_resource_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_sufficient_resources" {
  name        = "invoke_sufficient_resources"
  description = "Resource constraints: If there are not enough resources available in the cluster to create the desired number of pods, Kubernetes may not be able to start all of them."
  command     = "`chmod +x /agent/scripts/sufficient_resources.sh && /agent/scripts/sufficient_resources.sh`"
  params      = ["DESIRED_NUMBER_OF_PODS","YOUR_DEPLOYMENT","YOUR_NAMESPACE"]
  file_deps   = ["sufficient_resources"]
  enabled     = true
  depends_on  = [shoreline_file.sufficient_resources]
}

resource "shoreline_action" "invoke_check_k8s_deployment" {
  name        = "invoke_check_k8s_deployment"
  description = "Software bugs: There may be bugs in Kubernetes or other software components that are preventing pods from starting up as expected."
  command     = "`chmod +x /agent/scripts/check_k8s_deployment.sh && /agent/scripts/check_k8s_deployment.sh`"
  params      = []
  file_deps   = ["check_k8s_deployment"]
  enabled     = true
  depends_on  = [shoreline_file.check_k8s_deployment]
}

resource "shoreline_action" "invoke_pod_status_check" {
  name        = "invoke_pod_status_check"
  description = "Check the deployment configuration to ensure that the desired number of pods is correctly set."
  command     = "`chmod +x /agent/scripts/pod_status_check.sh && /agent/scripts/pod_status_check.sh`"
  params      = ["DEPLOYMENT_NAME"]
  file_deps   = ["pod_status_check"]
  enabled     = true
  depends_on  = [shoreline_file.pod_status_check]
}

resource "shoreline_action" "invoke_cluster_resource_check" {
  name        = "invoke_cluster_resource_check"
  description = "Check for any resource constraints that may be limiting the creation of new pods and adjust as necessary."
  command     = "`chmod +x /agent/scripts/cluster_resource_check.sh && /agent/scripts/cluster_resource_check.sh`"
  params      = []
  file_deps   = ["cluster_resource_check"]
  enabled     = true
  depends_on  = [shoreline_file.cluster_resource_check]
}

