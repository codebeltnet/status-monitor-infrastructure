resource "kubernetes_deployment" "this" {
  metadata {
    name = local.k8s_app
    labels = {
      app     = local.k8s_app
      service = local.k8s_service
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = local.k8s_app
        service = local.k8s_service
      }
    }

    template {
      metadata {
        labels = {
          app     = local.k8s_app
          service = local.k8s_service
        }
      }

      spec {
        container {
          image = "localstack/localstack:3.2.0"
          name  = local.k8s_app
          env {
            name  = "DEBUG"
            value = 0
          }
          env {
            name  = "DISABLE_CORS_CHECKS"
            value = 1
          }
          env {
            name  = "PARITY_AWS_ACCESS_KEY_ID"
            value = 1
          }
          port {
            container_port = local.k8s_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name = local.k8s_service
  }

  spec {
    selector = {
      app     = kubernetes_deployment.this.metadata.0.labels.app
      service = kubernetes_deployment.this.metadata.0.labels.service
    }
    type = "LoadBalancer"
    port {
      protocol = "TCP"
      port     = local.k8s_port
    }
  }
}

resource "aws_resourcegroups_group" "this" {
  name = local.tf_workspace

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Workspace",
      "Values": ["${local.tf_workspace}"]
    }
  ]
}
JSON
  }

  tags = local.default_tags

  depends_on = [
    kubernetes_deployment.this,
    kubernetes_service.this
  ]
}

resource "aws_ssm_parameter" "statusmonitor_worker_aws_calleridentity" {
  name  = "/${local.app_environment}/${local.app_namespace_worker}/AWS/CallerIdentity"
  type  = "String"
  value = var.aws_caller_identity

  tags = local.default_tags
}

resource "aws_ssm_parameter" "statusmonitor_worker_aws_sourcequeue" {
  name  = "/${local.app_environment}/${local.app_namespace_worker}/AWS/SourceQueue"
  type  = "String"
  value = "http://sqs.eu-west-1.localhost.localstack.cloud:4566"

  tags = local.default_tags

  depends_on = [
    kubernetes_deployment.this,
    kubernetes_service.this
  ]
}

resource "aws_sqs_queue" "status_monitor" {
  name                        = "status-monitor.fifo"
  fifo_queue                  = true
  content_based_deduplication = false

  tags = local.default_tags

  depends_on = [
    kubernetes_deployment.this,
    kubernetes_service.this
  ]
}

resource "aws_sqs_queue" "status_monitor_events" {
  name                        = "status-monitor-events.fifo"
  fifo_queue                  = true
  content_based_deduplication = false

  tags = local.default_tags

  depends_on = [
    kubernetes_deployment.this,
    kubernetes_service.this
  ]
}

resource "aws_sns_topic" "status_monitor" {
  name                        = "status-monitor-topic.fifo"
  fifo_topic                  = true
  content_based_deduplication = false

  tags = local.default_tags

  depends_on = [
    kubernetes_deployment.this,
    kubernetes_service.this
  ]
}

resource "aws_sns_topic_subscription" "status_monitor_sqs_target" {
  topic_arn            = aws_sns_topic.status_monitor.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.status_monitor_events.arn
  raw_message_delivery = true

  depends_on = [
    kubernetes_deployment.this,
    kubernetes_service.this
  ]
}
