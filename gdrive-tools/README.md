# gdrive-tools

Service-account CLI for reading and writing Google Drive files.

## Setup (per machine)

1. `npm install`
2. `.env` (gitignored, machine-local — not synced by dotfiles) sets `GOOGLE_APPLICATION_CREDENTIALS` to this machine's service account key path.
3. Share the target Drive folder with the service account's email (Viewer for `list`/`find`/`pull`, Editor for `push`/`create`).
4. The `gdrive` alias (in `../aliases`, sourced via `~/.aliases`) runs `cli.mjs` from anywhere.

## Commands

- `gdrive list <folderId>` — list files in a folder
- `gdrive find <folderId> <name-substring>` — search by name within a folder
- `gdrive pull <fileId> <localPath>` — download a file. Google Docs export as markdown, Sheets as CSV, Slides as PDF.
- `gdrive push <localPath> <fileId>` — overwrite an existing Drive file's content with a local file
- `gdrive create <localPath> <parentFolderId> [title]` — upload a local file as a new Drive file (markdown/text auto-converts to a Google Doc unless you pass a binary type)

Folder/file IDs are the id segment in the Drive URL (`.../folders/<id>` or `.../d/<id>/`).
