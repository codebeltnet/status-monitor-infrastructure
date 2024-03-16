resource "kubernetes_deployment" "local" {
  metadata {
    name = var.app
    labels = {
      app     = var.app
      service = var.service
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = var.app
        service = var.service
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app
          service = var.service
        }
      }

      spec {
        container {
          image = "localstack/localstack:3.2.0"
          name  = var.app
          port {
            container_port = var.port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "local" {
  metadata {
    name = var.service
  }

  spec {
    selector = {
      app     = kubernetes_deployment.local.metadata.0.labels.app
      service = kubernetes_deployment.local.metadata.0.labels.service
    }
    type = "LoadBalancer"
    port {
      protocol = "TCP"
      port     = var.port
    }
  }
}

resource "aws_sqs_queue" "status_monitor" {
  name                        = "status-monitor.fifo"
  fifo_queue                  = true
  content_based_deduplication = false

  tags = {
    Environment = var.environment
  }

  depends_on = [
    kubernetes_deployment.local,
    kubernetes_service.local
  ]
}

resource "aws_sqs_queue" "status_monitor_events" {
  name                        = "status-monitor-events.fifo"
  fifo_queue                  = true
  content_based_deduplication = false

  tags = {
    Environment = var.environment
  }

  depends_on = [
    kubernetes_deployment.local,
    kubernetes_service.local
  ]
}

resource "aws_sns_topic" "status_monitor" {
  name                        = "status-monitor-topic.fifo"
  fifo_topic                  = true
  content_based_deduplication = false

  tags = {
    Environment = var.environment
  }

  depends_on = [
    kubernetes_deployment.local,
    kubernetes_service.local
  ]
}

resource "aws_sns_topic_subscription" "status_monitor_sqs_target" {
  topic_arn            = aws_sns_topic.status_monitor.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.status_monitor_events.arn
  raw_message_delivery = true

  depends_on = [
    kubernetes_deployment.local,
    kubernetes_service.local
  ]
}
