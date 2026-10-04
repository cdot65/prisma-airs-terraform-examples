# Outputs: Inspect managed identities and discovery metadata without secret values.
output "adapter_id" {
  value = prisma-airs_red_team_adapter.example.id
}

output "adapter_status" {
  value = prisma-airs_red_team_adapter.example.status
}

output "target_id" {
  value = one(prisma-airs_red_team_target.example[*].id)
}

output "discovered_adapter_status" {
  value = data.prisma-airs_red_team_adapter.example.status
}
