# main.tf

resource "kubernetes_namespace" "this" {
  depends_on = [
    var.module_depends_on
  ]
  count = var.namespace == "" ? 1 : 0
  metadata {
    name = var.namespace_name
  }
}

resource "helm_release" "this" {
  depends_on = [
    var.module_depends_on
  ]
  name       = local.name
  repository = local.repository
  chart      = local.chart
  version    = local.version
  namespace  = local.namespace
  timeout    = 1200

  dynamic "set" {
    for_each = local.conf

    content {
      name  = set.key
      value = set.value
    }
  }
}
