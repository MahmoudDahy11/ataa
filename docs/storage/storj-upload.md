# Storj Upload Setup

The app now uses a backend-owned upload flow:

1. Flutter calls `POST /upload/init`
2. Backend validates the file and returns `{ url, fileKey }`
3. Flutter uploads bytes to Storj with `PUT`
4. Flutter calls `POST /upload/confirm`
5. Backend saves metadata in Firestore and marks the session used

## Backend environment

Keep all Storj credentials on the backend only.

```env
STORJ_ACCESS_KEY=
STORJ_SECRET_KEY=
STORJ_ENDPOINT=https://gateway.storjshare.io
STORJ_BUCKET=
MAX_FILE_SIZE=5242880
PORT=3000
```

The backend also needs Firebase Admin credentials available through the usual
`GOOGLE_APPLICATION_CREDENTIALS` flow or your deployment platform's secret
management.

## Flutter environment

Flutter only needs the backend base URL and the client-side size cap.

```env
UPLOAD_BASE_URL=https://your-upload-service.example.com
UPLOAD_MAX_BYTES=5242880
```

## Session model

Each upload is tracked in Firestore under `upload_sessions` with:

```json
{
  "fileKey": "users/{userId}/documents/{timestamp}_{random}.{ext}",
  "userId": "firebase uid",
  "used": false,
  "expiresAt": "timestamp",
  "createdAt": "timestamp"
}
```

Presigned URLs expire after 5 minutes. Upload sessions expire after 10 minutes.

## Local run

```sh
cd functions
npm install
npm run build
npm run dev
```

Point Flutter to the running service:

```env
UPLOAD_BASE_URL=http://localhost:3000
```

## Notes

- No Storj secrets live in Flutter.
- No client-side URL signing remains.
- No Storj bucket CORS configuration is required for this mobile-first flow.
- Files stay private and are referenced through Firestore metadata only.
