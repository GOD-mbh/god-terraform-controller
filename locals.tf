# locals.tf

locals {
  namespace      = coalescelist(kubernetes_namespace.this, [{ "metadata" = [{ "name" = var.namespace }] }])[0].metadata[0].name
  name       = var.internal ? "internal-nginx" : "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.chart_version

  conf = merge(local.conf_defaults, var.conf)
  conf_defaults = merge(
    var.aws_private ? {
      "controller.service.internal.enabled"                                                        = true
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal" = "0.0.0.0"
    } : {},
    var.internal ? {
      "controller.ingressClass"                                                                    = "internal"
      "controller.service.internal.enabled"                                                        = true
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal" = "0.0.0.0"
    } : {},
    {
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"                     = "nlb"
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags" = join(",", values({ for t in keys(var.tags) : t => "${t}=${var.tags[t]}" }))
      "rbac.create"                                                                                                = true
      "resources.limits.cpu"                                                                                       = "100m",
      "resources.limits.memory"                                                                                    = "300Mi",
      "resources.requests.cpu"                                                                                     = "100m",
      "resources.requests.memory"                                                                                  = "300Mi",
  })
}
