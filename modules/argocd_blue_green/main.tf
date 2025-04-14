resource "argocd_application_set" "list" {
  metadata {
    name = "blue-green-example"
  }

  spec {
    generator {
      list {
        elements = concat(
          [{
            name    = "app-svc"
            chart   = "blue-green-example-svc" # this chart can be reused by other apps
            color   = "unset"
            version = "0.1.0"
          }],
          (var.is_blue_up ?
            [{
              name    = "app-blue"
              chart   = "blue-green-example"
              color   = "blue"
              version = var.blue_version
          }] : []),
          (var.is_green_up ?
            [{
              name    = "app-green"
              chart   = "blue-green-example"
              color   = "green"
              version = var.green_version
          }] : []),
        )
      }
    }

    template {
      metadata {
        name      = "{{name}}"
        namespace = "argocd"
      }

      spec {
        project = "default"

        sync_policy {
          dynamic "automated" {
            for_each = var.auto_sync ? [1] : []
            content {
              prune       = false
              self_heal   = true
              allow_empty = false
            }
          }

          sync_options = [
            "CreateNamespace=true"
          ]
        }

        destination {
          server    = "https://kubernetes.default.svc"
          namespace = "test"
        }

        source {
          repo_url        = "example.com/my-repo/helm"
          chart           = "{{chart}}"
          target_revision = "{{version}}"

          helm {
            release_name = "{{name}}"

            parameter {
              name  = "color"
              value = "{{color}}"
            }

            parameter {
              name  = "routeToColor"
              value = var.route_to_color
            }
          }
        }
      }
    }
  }
}

locals {
  at_least_one_up = var.is_blue_up || var.is_green_up
  route_to_is_up  = var.route_to_color == "blue" && var.is_blue_up || var.route_to_color == "green" && var.is_green_up
}

resource "null_resource" "pre_checks" {
  lifecycle {
    precondition {
      condition     = local.at_least_one_up
      error_message = "One of blue or green must be up."
    }
    precondition {
      condition     = local.route_to_is_up
      error_message = "Cannot route to ${var.route_to_color} because it is not up."
    }
  }
}
