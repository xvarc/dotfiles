import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";
import { google } from "googleapis";

dotenv.config({ path: path.join(path.dirname(fileURLToPath(import.meta.url)), "..", ".env") });

export function getDrive() {
  const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!keyPath || !fs.existsSync(keyPath)) {
    console.error("Set GOOGLE_APPLICATION_CREDENTIALS in .env to the service account key path.");
    process.exit(1);
  }
  const creds = JSON.parse(fs.readFileSync(keyPath, "utf8"));
  const auth = new google.auth.GoogleAuth({
    credentials: creds,
    scopes: ["https://www.googleapis.com/auth/drive"],
  });
  return google.drive({ version: "v3", auth });
}

// Native Google types can't be downloaded raw — they must be exported to a real format.
export const GOOGLE_EXPORT_MIME = {
  "application/vnd.google-apps.document": "text/markdown",
  "application/vnd.google-apps.spreadsheet": "text/csv",
  "application/vnd.google-apps.presentation": "application/pdf",
};

const EXT_MIME = {
  md: "text/markdown",
  markdown: "text/markdown",
  txt: "text/plain",
  csv: "text/csv",
  json: "application/json",
  pdf: "application/pdf",
  png: "image/png",
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
};

export function guessMime(filePath) {
  const ext = filePath.split(".").pop().toLowerCase();
  return EXT_MIME[ext] || "application/octet-stream";
}
