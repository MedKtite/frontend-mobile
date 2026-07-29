# Endpoint Relationships with Document Ingestion

This document explains how uploading a document, creating a book, and processing
that document are connected.

## Main relationship

```text
POST /me/uploads/presign
        ↓
Client uploads file directly to the returned uploadUrl
        ↓
POST /me/books  { ..., fileKey }
        ↓
Book is saved in the user's library
        ↓
For PDF/EPUB: backend creates an ingestion job automatically
        ↓
GET /me/books/{bookId}/ingestion-jobs/{jobId}
        ↓
When processing finishes, use the reading-download endpoint
```

## 1. Request an upload URL

```http
POST /me/uploads/presign
```

The frontend sends the file format, content type, and file size. The backend
returns a `fileKey`, an `uploadUrl`, the upload method, and an expiration time.

The backend validates the format/content type and creates a user-isolated key:

```text
users/{userId}/uploads/{random-id}.{format}
```

This endpoint does not create a library book and does not create an ingestion
job.

## 2. Upload the file

The frontend sends the file bytes directly to the returned `uploadUrl`, normally
with an HTTP `PUT`. The backend application does not receive the file bytes.

The upload must finish successfully before creating the book.

## 3. Create the library book

```http
POST /me/books
```

The frontend sends the book metadata and the returned `fileKey`.

For digital books (`pdf`, `epub`, `m4b`, or `mp3`), `fileKey` is required. The
backend verifies that:

- The key belongs to the current user.
- The uploaded object exists.
- A physical book does not incorrectly contain a file key.

The backend then creates the book in the user’s library.

## 4. Automatic ingestion for PDF and EPUB

When the created book has a file and its format is `pdf` or `epub`, the backend:

1. Sets the book's `processingStatus` to `pending`.
2. Creates an ingestion job with job type `UPLOAD_DOCUMENT`.
3. Uses the book's `fileKey` as the job's `sourceKey`.
4. Returns the created book from `POST /me/books`.

Therefore, the frontend normally does not need to create the first ingestion
job itself after a normal PDF/EPUB book creation.

## 5. Manually create an ingestion job

```http
POST /me/books/{bookId}/ingestion-jobs
```

Request body:

```json
{
  "jobType": "UPLOAD_DOCUMENT",
  "sourceKey": "users/{userId}/uploads/book.pdf",
  "payload": {
    "format": "pdf"
  }
}
```

`jobType` is required. `sourceKey` and `payload` are optional according to the
request DTO. The backend first verifies that the book belongs to the logged-in
user, then creates the job and returns HTTP `202 Accepted`.

Use this endpoint only when the frontend explicitly needs to request another
processing job, such as a retry or a separate ingestion operation.

## 6. Check ingestion status

```http
GET /me/books/{bookId}/ingestion-jobs/{jobId}
```

The backend verifies both the book owner and the relationship between `jobId`
and `bookId`. It returns:

| Field | Meaning |
|---|---|
| `id` | Ingestion job identifier. |
| `bookId` | Book being processed. |
| `jobType` | Type of processing requested. |
| `sourceKey` | Storage key used as the source. |
| `status` | Current job state. |
| `attempts` | Number of processing attempts. |
| `result` | Processing output, when available. |
| `errorMessage` | Failure details, when processing failed. |
| `createdAt` | Time the job was created. |
| `startedAt` | Time processing started. |
| `finishedAt` | Time processing finished. |

## 7. Download the processed book for reading

```http
GET /me/books/{bookId}/reading-download-url
```

This returns a temporary download URL. For PDFs, the backend can create or use
a reflowed EPUB so the reader can use a better reading format. The frontend
should request this URL when opening the book, rather than assuming that the
original upload is immediately readable.

For the original file instead, use:

```http
GET /me/books/{bookId}/download-url
```

## Frontend implementation sequence

### Digital PDF/EPUB book

```text
1. POST /me/uploads/presign
2. PUT uploadUrl with the file bytes
3. POST /me/books with fileKey and metadata
4. Read processingStatus from the returned book
5. If processing is pending, poll the ingestion-job endpoint
6. Open the book with /reading-download-url
```

### Physical book

```text
1. POST /me/books with format: "physical"
2. Do not send fileKey
3. No upload or ingestion job is required
```

### Audio book

```text
1. POST /me/uploads/presign
2. PUT uploadUrl with the audio file
3. POST /me/books with format: "m4b" or "mp3" and fileKey
4. Open/download using the book download endpoint
```

## Important distinction

| Endpoint | Creates library book? | Creates ingestion job? | Main purpose |
|---|---:|---:|---|
| `POST /me/uploads/presign` | No | No | Prepare a direct file upload. |
| `POST /me/books` | Yes | Yes, automatically for PDF/EPUB | Add the book and start document processing when needed. |
| `POST /me/books/{bookId}/ingestion-jobs` | No | Yes | Explicitly request processing for an existing book. |
| `GET /me/books/{bookId}/ingestion-jobs/{jobId}` | No | No | Check processing status. |
| `GET /me/books/{bookId}/reading-download-url` | No | May generate a PDF reflow artifact | Get a readable temporary file URL. |
