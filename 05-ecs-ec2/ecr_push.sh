set -e

TAG=latest
REGION=$(terraform output -raw region)
REPO_URL=$(terraform output -raw repository_url)

DOCKER_LOGIN_URL=$(echo "$REPO_URL" | cut --delimiter="/" --fields 1)

echo "building docker image"
cd ./hello-world-service
docker build -f Dockerfile -t $REPO_URL:$TAG .

echo "ecr login"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $DOCKER_LOGIN_URL

echo "pushing to ecr"
docker push $REPO_URL:$TAG