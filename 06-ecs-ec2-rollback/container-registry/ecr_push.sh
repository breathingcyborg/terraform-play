#!/bin/bash

set -e

version=""
crash=""

usage() {
  cat <<EOF
Usage: $0 -v <version> -c <true|false>

Builds and pushes new container image to ecr.
When -c argument is true, the api would crash.

Options:
  -v   Version number (required)
  -c   Crash flag: true|false (required)
EOF

  exit 1
}

while getopts "v:c:" opt; do
  case "$opt" in
    v) version="$OPTARG" ;;
    c) crash="$OPTARG" ;;
    *) usage ;;
  esac
done

[ -z "$version" ] && usage
[ -z "$crash" ] && usage


REGION=$(terraform output -raw repo_region)

REPO_URL=$(terraform output -raw repo_url)

DOCKER_LOGIN_URL=$(echo "$REPO_URL" | cut --delimiter="/" --fields 1)

echo "Building & tagging docker image"
cd ./dummy-api
docker build -t $REPO_URL:latest -t $REPO_URL:$version --build-arg CRASH=$crash .

echo "ECR Login"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $DOCKER_LOGIN_URL

echo "Pushing to ecr"
docker push $REPO_URL:$version
docker push $REPO_URL:latest