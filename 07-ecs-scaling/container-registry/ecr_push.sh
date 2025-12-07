#!/bin/bash

set -e

version=""

usage() {
  cat <<EOF
Usage: $0 -v <version>

Builds and pushes new container image to ecr.

Options:
  -v   Version number (required)
EOF

  exit 1
}

while getopts "v:" opt; do
  case "$opt" in
    v) version="$OPTARG" ;;
    *) usage ;;
  esac
done

[ -z "$version" ] && usage

REGION=$(terraform output -raw repo_region)
REPO_URL=$(terraform output -raw repo_url)
DOCKER_LOGIN_URL=$(echo "$REPO_URL" | cut --delimiter="/" --fields 1)

echo "Building & tagging docker image"
cd ./dummy-api
docker build -t $REPO_URL:latest -t $REPO_URL:$version .

echo "ECR Login"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $DOCKER_LOGIN_URL

echo "Pushing to ecr"
docker push $REPO_URL:$version
docker push $REPO_URL:latest