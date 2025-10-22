# Image resize lambda

This lambda runs sits between cloudfront and s3, it runs when s3 returns response to cloudfront. Lambda intercepts 404 response from s3 it resizes the image according to the dimensions specified in the url, and saves the resized image to s3 and then returns the resized image in the response.

## Region
- this lambda must be in `us-east-1` region, it can interact with bucket in different region but it must be in `us-east-1` for lambda@edge to work

## Change bucket name and region
In index.mjs `BUCKET_REGION` and `BUCKET` variables are defined that can be changed as needed. This lambda runs on edge so it cannot use environment variables so these variables are hardcoded.

## Testing lamba
1. run node ./test-parse-params.mjs and verify the outpu
2. In aws console test lambda using event in `./test-event-resize.json`. It should return 200 response and a base64 encoded resized image.
3. In aws console test lambda using event in `./test-event-original.json`. It should return 200 without base64 resized image in response.

## Packing code.
Add everything in the current directory including `node_modules` except `packgage.json` and `package-lock.json` in a zip file. Upload this zip file to lambda.

## What if image resize fails because of timeout or out of memory errors.
This lambda runs on edge locations it should responsd within 30 seconds, unlike reglar lambda that can take upto 15 minutes. So we need to increase cpu / ram that lambda can use.
