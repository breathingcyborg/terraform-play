import { S3Client, GetObjectCommand, PutObjectCommand } from '@aws-sdk/client-s3';
import Sharp from 'sharp';
import { parseParamsFromUrl } from './parse-params-from-uri.mjs'; 

// Bucket region
const BUCKET_REGION = 'us-east-1';

// Replace bucket name in production
const BUCKET = 'tfplay-uploads-85';

// Initialize the S3 client
const s3 = new S3Client({
    signatureVersion: 'v4',
    region: BUCKET_REGION,
});

async function s3StreamToBuffer(stream) {
    return Buffer.concat(await stream.toArray())
}

// See this for event schema
// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html#lambda-event-structure-response-origin#lambda-event-structure-response-origin

export const handler = async (event, context, callback) => {
    const request = event.Records[0].cf.request;
    const response = event.Records[0].cf.response;

    if (response.status !== '404') {
        // console.log("response not 404", response.status);
        callback(null, response);
        return;
    }

    const uri = request.uri;
    const parmas = parseParamsFromUrl(uri);
    // console.log("url, variant", uri, variant);

    if (!parmas) {
        // Invalid file pattern
        callback(null, response);
        return;
    }

    const {
        extension,
        options: resizeOptions,
        originalKey
    } = parmas;

    // remove / from the url
    const newKey = uri.substring(1)

    console.log("originalKey", originalKey);
    console.log("newKey", newKey);

    try {

        // Fetch the original image from S3
        const data = await s3.send(new GetObjectCommand({
            Bucket: BUCKET,
            Key: originalKey,
        }));
        
        // console.log("fetch original");
        
        if (!data || !data.Body) {
            // console.log("original not found");
            throw new Error('No data returned from S3');
        }
        
        // console.log("converting stream to buffer");

        const bodyBuffer = await s3StreamToBuffer(data.Body);

        // console.log("resizing");

        // Resize the image with Sharp
        const buffer = await Sharp(bodyBuffer)
            .resize(resizeOptions)
            .toFormat(extension,  { quality: 80 })
            .toBuffer();

        // console.log("resized");
        // console.log("otherParams", {
        //     Bucket: BUCKET,
        //     ContentType: `image/${extension}`,
        //     CacheControl: 'max-age=31536000',
        //     Key: newKey, // Store under the same key as the request URI
        //     StorageClass: 'STANDARD'
        // });
        // console.log("uploading");

        // Store the resized image back into the S3 bucket
        await s3.send(new PutObjectCommand({
            Body: buffer,
            Bucket: BUCKET,
            ContentType: `image/${extension}`,
            CacheControl: 'max-age=31536000',
            Key: newKey, // Store under the same key as the request URI
            StorageClass: 'STANDARD'
        }));

        // console.log("uploaded");

        // Return the resized image to the CloudFront viewer
        response.status = 200;
        response.body = buffer.toString('base64');
        response.bodyEncoding = 'base64';
        response.headers['content-type'] = [
            { key: 'Content-Type', value: `image/${extension}` }
        ]

        // console.log("calling callback");

        callback(null, response);

        // console.log("calling called");


    } catch (err) {

        console.error('Error processing image:', err);
        // Return original 404 response if there’s an error
        callback(null, response);

    }
};