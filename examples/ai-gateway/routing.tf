# Targets: Reuse the primary connection when no secondary upstream is supplied.
locals {
  secondary_upstream = coalesce(var.secondary_upstream, var.primary_upstream)

  primary_target = {
    provider = "@${prisma-airs_gateway_provider.models[var.primary_upstream].slug}"

    override_params = {
      model = var.primary_model
    }
  }

  secondary_target = {
    provider = "@${prisma-airs_gateway_provider.models[local.secondary_upstream].slug}"

    override_params = {
      model = var.secondary_model
    }
  }

  routing_configs = {
    # Fallback: Try ordered targets on configured failures, with bounded retries.
    fallback = {
      strategy = {
        mode            = "fallback"
        on_status_codes = var.fallback_status_codes
      }

      targets = [local.primary_target, local.secondary_target]

      retry = {
        attempts        = var.retry_attempts
        on_status_codes = [429, 500, 502, 503, 504]
      }
    }

    # Balancing: Weight target selection; a small sample may differ from the ratio.
    balanced = {
      strategy = {
        mode = "loadbalance"
      }

      targets = [
        merge(local.primary_target, { weight = var.primary_weight }),
        merge(local.secondary_target, { weight = 100 - var.primary_weight }),
      ]
    }

    # Conditional routing: Premium metadata selects secondary; other requests use primary.
    conditional = {
      strategy = {
        mode    = "conditional"
        default = "primary"

        conditions = [
          {
            query = {
              "metadata.tier" = {
                "$eq" = "premium"
              }
            }
            then = "secondary"
          },
        ]
      }

      targets = [
        merge(local.primary_target, { name = "primary" }),
        merge(local.secondary_target, { name = "secondary" }),
      ]
    }

    # Cache: Reuse identical requests within the configured simple-cache lifetime.
    cached = merge(local.primary_target, {
      cache = {
        mode    = "simple"
        max_age = var.cache_max_age
      }
    })
  }
}
