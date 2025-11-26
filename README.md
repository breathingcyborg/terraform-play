## Terraform play

Just playing around with terraform.

1. `01-vpc-ec2-nomodule` - single ec2, with vpc and sg (to get familiar with terraform workflow)
2. `02-vpc-ec2-module` - same as above, with ssh key, and vpc module
3. `03-image-resize-pipeline` - dynamic image resize pipeline, the resizes images on the fly, uses s3, cloudfront, lambda@edge
4. `04-api-gateway-lambda` - api gateway with 2 lambdas one for auth and other for api, uses dynamodb
5. `05-ecs-ec2` -  container deployed on ecs cluster, backed by ec2 auto scaling group capacity provider, with ipv6 support
6. `06-ecs-ec2-rollback` - similar to `05-ecs-ec2` but rollbacks deployment if it fails, and uses 2 terraform stack one for container registry and one for ecs cluster
