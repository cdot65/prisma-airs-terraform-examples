mock_provider "prisma-airs" {}
variables {
  name_prefix         = "tf-test-redteam"
  target_endpoint     = "https://application.example.com/chat"
  request_body        = { prompt = "{INPUT}" }
  response_body       = { answer = "{RESPONSE}" }
  response_key        = "answer"
  target_auth_headers = { Authorization = "Bearer mock-key" }
}
run "authenticated_target" {
  command = plan
}
