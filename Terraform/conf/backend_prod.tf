terraform {
  backend "s3" {
    bucket = "tf-remote-backend-cloudopshub"
    key    = "cloudopshub/prod/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
}
}