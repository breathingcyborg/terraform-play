bucket_name=$(terraform output -raw bucket_name)
aws s3 cp ./image.jpg s3://$bucket_name/