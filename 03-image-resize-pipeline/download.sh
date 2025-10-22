
echo "Downloading from s3 at temp/original.jpg"
bucket_domain="https://$(terraform output -raw bucket_domain)"
original_url=$bucket_domain/image.jpg
curl -s -o ./temp/original.jpg $original_url

echo "Downloading from cloudfront at temp/original_cloudfront.jpg"
cdn_domain="https://$(terraform output -raw cdn_domain)"
cdn_original_url=$cdn_domain/image.jpg
curl -s -o ./temp/original_cloudfront.jpg $cdn_original_url

echo "Downloading 100x100 image from cloudfront at temp/cloudfront_100x100.jpg"
cdn_domain="https://$(terraform output -raw cdn_domain)"
cdn_original_url=$cdn_domain/100x100/image.jpg
curl -s -o ./temp/cloudfront_100x100.jpg $cdn_original_url
