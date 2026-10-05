# State: One canonical tenant state; Conjur supplies credentials through the environment.
terraform {
  backend "s3" {
    bucket = "my-prisma-airs-state"
    key    = "state/tenant.tfstate"
    region = "us-east-1"

    # Coordination: Conditional S3 writes protect the shared state during every operation.
    use_lockfile = true

    # Compatibility: The endpoint is MinIO, configured with AWS_ENDPOINT_URL_S3.
    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
