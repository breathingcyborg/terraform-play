# ECS With autoscaling based on number of requests & custom domain

- service autoscales when alb gets more than 60 requests per minute, for atleast 3 cycles, 1 cycle is 1 minute
- uses custom domain (without route53 as it costs $0.50 per month per route53 hosted zone)

## 1. Create ecr repo
```sh
cd ./container-registry
terraform apply
```

**Build & push docker image**
```sh
cd ./container-registry
./ecr_push.sh -v 1.0.0 -c false
```

## 2. Create ssl cert

Enter domain name when asked
```sh
cd ./ssl
terraform apply
```

**Create CNAME record in you domain provider account for validation**
print CNAME record for validation
```sh
cd ./ssl
terraform output
```

It should print something like this
```sh
validation_options = toset([
  {
    "domain_name" = "tfplay7.example.com"
    "resource_record_name" = "_adfasfasdf_.tfplay7.example.com."
    "resource_record_type" = "CNAME"
    "resource_record_value" = "_asdfsdfasdf_.asdfsdf.acm-validations.aws."
  },
])
```

Add this DNS record in your domain provider account

Wait for certificate to be issued, creating alb listener for https would fail if certificate is not yet issued.

## 3. Create infra
```sh
cd ./ecs
terraform apply -var="docker_image_version=1.0.0"
```

**add CNAME record to point you domain to aws**
```sh
terraform output
```

Should print something like below
```sh
alb_url = "tf-lb-asdfsadf-asdfsd.us-east-1.elb.amazonaws.com"
domain_name = "tfplay7.example.com"
```

Add record to you dns record, type: CNAME, name: domain_name, value: alb_url, note some domain providers need only the subdomain part for name `tfplay7` and others need both domain and subdomain like this `tfplay7.example.com`

Wait for a while for dns changes to propogate

You can use this to check
```sh
nslookup -type=CNAME tfplay7.example.com
```

## 4. Send requests to trigger service autoscaling
```sh
./send-traffic-to-autoscale.sh
```