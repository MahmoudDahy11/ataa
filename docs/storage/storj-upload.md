# Storj Upload Setup

The Flutter app calls the Firebase Functions upload API, receives a presigned
PUT URL, and uploads bytes directly to Storj.

## Firebase Functions configuration

Set the Storj values on the backend only. Do not put these secrets in Flutter.

```sh
firebase functions:secrets:set STORJ_ACCESS_KEY
firebase functions:secrets:set STORJ_SECRET_KEY
firebase deploy --only functions
```

After deploy, point Flutter at the Functions base URL:

```env
UPLOAD_BASE_URL=https://us-central1-ebra-app.cloudfunctions.net/uploadApi
```

The `uploadApi/init-upload` route returns both `signedUrl` and `uploadUrl`.
The signed URL is path-style and starts with:

```text
https://gateway.storjshare.io/ataa/
```

## CORS

The standard S3 CORS config is in `docs/storage/storj-cors.json`.

```sh
AWS_ACCESS_KEY_ID="YOUR_STORJ_ACCESS_KEY" AWS_SECRET_ACCESS_KEY="YOUR_STORJ_SECRET_KEY" aws s3api put-bucket-cors --endpoint-url https://gateway.storjshare.io --bucket ataa --cors-configuration file://docs/storage/storj-cors.json
```

Storj's hosted Gateway-MT compatibility table currently marks `PutBucketCors`
as unsupported. Native Flutter mobile uploads are not blocked by browser CORS.
For Flutter Web, use a proxy upload endpoint or a gateway option that supports
browser preflight/CORS.
