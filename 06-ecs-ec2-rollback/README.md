# ECS With rolling update

- ecs cluster with ec2 (asg) capacity provider
- uses ipv6
- rollback on failure

## Create ecr repo
```sh
cd ./container-registry
terraform apply
```

## For successfull deployment

**Build & push docker image**
```sh
cd ./container-registry
./ecr_push.sh -v 1.0.0 -c false
```

**Update infra**
```sh
cd ./ecs
terraform apply -var="docker_image_version=1.0.0"
```

## For failed deployment

**Build & push docker image**

The -c true builds docker image that fails with error 500
```sh
cd ./container-registry
./ecr_push.sh -v 1.0.1 -c true
```

**Update infra**
```sh
cd ./ecs
terraform apply -var="docker_image_version=1.0.1"
```
