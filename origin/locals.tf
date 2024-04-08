locals {
  app_environment       = "LocalDevelopment"
  app_namespace         = "Codebelt.StatusMonitor"
  app_namespace_restapi = "${local.app_namespace}.RestApi"
  app_namespace_worker  = "${local.app_namespace}.Worker"
  default_tags = {
    Environment       = local.app_environment
    Workspace         = local.tf_workspace
    ApplicationUri    = "https://github.com/codebeltnet/status-monitor"
    InfrastructureUri = "https://github.com/codebeltnet/status-monitor-infrastructure"
  }
  k8s_app      = "localstack"
  k8s_service  = "localstack-svc"
  k8s_port     = 4566
  tf_workspace = "status-monitor-origin"
}
