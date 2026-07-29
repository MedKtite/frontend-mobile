# Marginalia Backend API — Endpoint Jobs

This document summarizes the endpoints currently exposed by the backend controllers.
Most `/me/**` endpoints require the authenticated user session. Authentication uses
HttpOnly cookies.

## Authentication — `/auth`

| Method | Endpoint | Job |
|---|---|---|
| POST | `/auth/register` | Create a new user account and start a session. |
| POST | `/auth/login` | Authenticate with email/password and start a session. |
| POST | `/auth/oauth/google` | Authenticate or register using Google OAuth. |
| POST | `/auth/oauth/x` | Authenticate or register using X OAuth. |
| POST | `/auth/refresh` | Refresh the access session using the refresh cookie. |
| POST | `/auth/logout` | End the current session and clear auth cookies. |
| POST | `/auth/password/forgot` | Start the password-reset process. |
| POST | `/auth/password/reset` | Set a new password using a reset token. |

## Books / Library — `/me/books`

| Method | Endpoint | Job |
|---|---|---|
| GET | `/me/books` | List the current user’s library. Optional `status` filters the list. |
| GET | `/me/books/{id}` | Get one library book. |
| POST | `/me/books` | Add a book to the current user’s library. Handles metadata, uploaded files, free-tier limits, and document-processing jobs. |
| PATCH | `/me/books/{id}` | Update reading state such as status, progress, or cursor. |
| DELETE | `/me/books/{id}` | Remove a book from the library and clean up its stored files. | 
| GET | `/me/books/{id}/download-url` | Get a temporary URL for downloading the original book file. | **
| GET | `/me/books/{id}/reading-download-url` | Get a temporary URL for reading; may generate/use a reflowed EPUB for PDFs. | **
| GET | `/me/books/{id}/file` | Stream the book file through the backend, mainly for the web client. | ** 

## Catalog — `/me/catalog`

| Method | Endpoint | Job |
|---|---|---|
| GET | `/me/catalog/search` | Search external/catalog books. | 
| GET | `/me/catalog/gutenberg-epub/{gutenbergId}` | Download a Project Gutenberg EPUB. |
| GET | `/me/catalog/lookup` | Look up one catalog book by its external identifier. | **
| GET | `/me/catalog/librivox` | Get LibriVox audiobook information. |
| GET | `/me/catalog/recommendations` | Return book recommendations. | ** 
| POST | `/me/catalog/requests` | Request a catalog book that is not currently available. |

## Uploads — `/me/uploads`

| Method | Endpoint | Job |
|---|---|---|
| POST | `/me/uploads/presign` | Create a presigned upload URL. The client uploads the file, then uses the returned `fileKey` when creating the book. | **

## Highlights — `/me/highlights`

| Method | Endpoint | Job |
|---|---|---|
| GET | `/me/highlights` | List recent highlights. |
| GET | `/me/highlights/by-book/{bookId}` | List highlights belonging to a book. |
| GET | `/me/highlights/saved` | List saved highlights. |
| GET | `/me/highlights/by-tag/{tagId}` | List highlights associated with a tag. |
| GET | `/me/highlights/{id}` | Get one highlight. |
| POST | `/me/highlights` | Create a highlight. |
| PATCH | `/me/highlights/{id}` | Edit a highlight, including saved state or content. |
| DELETE | `/me/highlights/{id}` | Delete a highlight. |
| GET | `/me/highlights/{id}/tags` | List tags attached to a highlight. | **
| POST | `/me/highlights/{id}/tags/{tagId}` | Attach a tag to a highlight. | **
| DELETE | `/me/highlights/{id}/tags/{tagId}` | Remove a tag from a highlight. |

## Notes — `/me/notes`

| Method | Endpoint | Job |
|---|---|---|
| GET | `/me/notes` | List recent notes. |
| GET | `/me/notes/saved` | List saved notes. |
| GET | `/me/notes/by-book/{bookId}` | List notes belonging to a book. |
| GET | `/me/notes/by-highlight/{highlightId}` | List notes attached to a highlight. | **
| GET | `/me/notes/{id}` | Get one note. |
| POST | `/me/notes` | Create a note. |
| PATCH | `/me/notes/{id}` | Edit a note. |
| DELETE | `/me/notes/{id}` | Delete a note. |

## Reading — `/me/reading-sessions`

| Method | Endpoint | Job |
|---|---|---|
| GET | `/me/reading-sessions` | List recent reading sessions. |
| GET | `/me/reading-sessions/by-book/{bookId}` | List sessions for a book. | **
| POST | `/me/reading-sessions` | Record a reading/listening session. | **

## Search and Insights

| Method | Endpoint | Job |
|---|---|---|
| GET | `/me/search` | Search the user’s library and related content. | 
| GET | `/me/insights` | Return reading insights and statistics. |

## Tags

| Method | Endpoint | Job |
|---|---|---|
| GET | `/tags` | List public/system tags. |
| GET | `/me/tags` | List the current user’s tags. |
| GET | `/me/tags/counts` | Return usage counts for the user’s tags. |
| POST | `/me/tags` | Create a personal tag. |
| PATCH | `/me/tags/{id}` | Rename or update a personal tag. |
| DELETE | `/me/tags/{id}` | Delete a personal tag. |

## Preferences and Account Services

| Method | Endpoint | Job |
|---|---|---|
| GET | `/me/preferences` | Get user preferences. |
| PATCH | `/me/preferences` | Update user preferences. |
| GET | `/me/notifications` | Get notification preferences. |
| PATCH | `/me/notifications` | Update notification preferences. |
| GET | `/me/subscription` | Get the current subscription/plan status. |

## Devices — `/me/devices` **

| Method | Endpoint | Job |
|---|---|---|
| GET | `/me/devices` | List registered devices. |
| POST | `/me/devices` | Register a device. |
| DELETE | `/me/devices/{id}` | Remove a registered device. |

## Document Ingestion — `/me/books/{bookId}/ingestion-jobs` **

| Method | Endpoint | Job |
|---|---|---|
| POST | `/me/books/{bookId}/ingestion-jobs` | Create/start an ingestion job for a book document. |
| GET | `/me/books/{bookId}/ingestion-jobs/{jobId}` | Get ingestion-job status and result information. |

## Cover Proxy **

| Method | Endpoint | Job |
|---|---|---|
| GET | `/covers` | Proxy a remote cover image through the backend. This helps clients that cannot fetch the original image URL directly. |

## Webhooks

| Method | Endpoint | Job |
|---|---|---|
| POST | `/webhooks/revenuecat` | Receive subscription/purchase events from RevenueCat. |

## Common frontend mapping

| Frontend action | Backend endpoint |
|---|---|
| Login | `POST /auth/login` |
| Add to library | `POST /me/books` |
| Change progress/status | `PATCH /me/books/{id}` |
| Load library | `GET /me/books` |
| Add highlight | `POST /me/highlights` |
| Add note | `POST /me/notes` |
| Upload a file | `POST /me/uploads/presign`, then upload to the returned URL |
| Get book for reading | `GET /me/books/{id}/reading-download-url` |
| Remove from library | `DELETE /me/books/{id}` |
