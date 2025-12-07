# ECS With autoscaling based on number of requests per alb target

- service autoscales when alb gets more than 60 requests per minute, for atleast 3 cycles, 1 cycle is 1 minute

## Create ecr repo
```sh
cd ./container-registry
terraform apply
```

**Build & push docker image**
```sh
cd ./container-registry
./ecr_push.sh -v 1.0.0 -c false
```

## Create infra
```sh
cd ./ecs
terraform apply -var="docker_image_version=1.0.0"
```

## Send requests to trigger service autoscaling
```sh
./send-traffic-to-autoscale.sh
```