output "routing" {
  description = "Routing identifiers; application keys select each policy."
  value = { for mode, config in prisma-airs_gateway_config.routing : mode => {
    id = config.id, slug = config.slug, version_id = config.version_id
  } }
}
output "application_keys" {
  description = "One-time application credentials; protect sensitive state."
  sensitive   = true
  value       = { for mode, key in prisma-airs_gateway_service_api_key.application : mode => key.key }
}
output "application_metadata" { value = { application = var.name_prefix } }
output "request_model" {
  value = "@${prisma-airs_gateway_provider.models[var.primary_upstream].slug}/${var.primary_model}"
}
output "runtime_profile_name" { value = prisma-airs_runtime_security_profile.gateway.profile_name }
output "guardrail_slugs" {
  value = {
    marker = prisma-airs_gateway_guardrail.marker.slug
    airs   = prisma-airs_gateway_guardrail.airs.slug
  }
}
output "org_guardrail_slug" {
  value = var.enable_org_guardrail ? prisma-airs_gateway_org_guardrail.baseline[0].slug : null
}
output "mcp_server_slug" {
  value = var.enable_mcp ? prisma-airs_gateway_mcp_server.tools[0].slug : null
}
output "secret_reference_id" {
  value = var.secret_manager == null ? null : prisma-airs_gateway_secret_reference.upstream[0].id
}
output "developer_api_key" {
  sensitive = true
  value     = var.developer_user_id == null ? null : prisma-airs_gateway_user_api_key.developer[0].key
}
output "deployment_credentials" {
  sensitive = true
  value     = var.enable_deployment_registration ? prisma-airs_gateway_deployment.hybrid[0].credentials : null
}
