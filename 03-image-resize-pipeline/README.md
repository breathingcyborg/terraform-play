# Dynamic Image Resize

### Flow
- s3 bucket stores uploaded images
- cloudfront distribution server images from s3
- when user needs resized image they can use url like `/100x100/image.jpg`
- a lambda function is executed on `origin response`, it sees that the image dosent exist, so it resizes the image and saves it back to s3, and also returns the resized image to user
- next time when request for the same image `/100x100/image.jpg` arrives, couldfront fetches image from s3 and caches it

### Config and check
- in `./code/index.mjs`, replace region and name of your bucket
- from `./code` run npm install
- excute `terraform apply -var="bucket_name=your_bucket_name"`
- run `./upload.sh` to upload to s3.
- run `./download.sh` to download original and resized images.
- if 3 images are downloaded in `./temp`, code works

### Permission error
- if you get permission error on cloudfront, reading lambda dosent have sufficient permissions to execute
- in lambda.tf check handler `index.handler` means, in index.js file, a function exported as `handler`

### Lambda@Edge limitations
- we use lambda@edge for resizing image
- its has max 30s timeout, unlike lambda which has 15 minutes
- it cannot use environment variables
- so bucket and region are hardcoded in `./code/index.mjs`

Image credit:
https://unsplash.com/@sierraburtis