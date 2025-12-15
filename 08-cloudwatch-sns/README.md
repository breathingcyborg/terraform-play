# Send email using sns when cpu average cpu utilization 70%

## Cloudwatch metrics and alarms

- by default ec2 sends metrics to cloudwatch once every 5 minutes

- we created alarm with

```
period: 60 (1 minute)
threshold: 70 (70% cpu util)
evaluation_periods: 1
```

So according to our config, we should get alarm should trigger when we have >=70% cpu utilization for atleast 1 period, where 1 period is 60 seconds.

- but since ec2 sends data once every 5 minutes, we should continue stress testing for atleast 5 minutes for alarm to trigger

## create infra

```
cd ./08-cloudwatch-sns
terraform apply
```

Enter email when asked

## Confirm email subsription
you would receive email from aws with a link to confirm your subscription

## Stress test

Login to ec2
```sh
cd ./08-cloudwatch-sns
EC2_IP=$(terraform output -raw ec2_ipv6)
ssh -i ../tf-play-ssh-key -o IdentitiesOnly=yes ubuntu@"$EC2_IP"
```

install stress testing util
```sh
sudo apt update
sudo apt install stress
```

stress cpu for 5 minutes

```sh
stress -c 4 --timeout 300
```

You should get an email from aws