## Terraform play

Just playing around with terraform.

1. `01-vpc-ec2-nomodule` - single ec2, with vpc and sg (to get familiar with terraform workflow)
2. `02-vpc-ec2-module` - same as above, with ssh key, and vpc module
3. `03-image-resize-pipeline` - dynamic image resize pipeline, the resizes images on the fly, uses s3, cloudfront, lambda@edge