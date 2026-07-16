#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { getDrive, GOOGLE_EXPORT_MIME, guessMime } from "./lib/drive.mjs";

function usage(specific) {
  console.error(`Usage: gdrive ${specific || "<list|find|pull|push|create> ..."}`);
  process.exit(1);
}

async function list(folderId) {
  if (!folderId) usage("list <folderId>");
  const drive = getDrive();
  const res = await drive.files.list({
    q: `'${folderId}' in parents and trashed = false`,
    fields: "files(id,name,mimeType,modifiedTime)",
    orderBy: "name",
  });
  console.log(JSON.stringify(res.data.files, null, 2));
}

async function find(folderId, ...nameParts) {
  const name = nameParts.join(" ");
  if (!folderId || !name) usage("find <folderId> <name-substring>");
  const drive = getDrive();
  const res = await drive.files.list({
    q: `'${folderId}' in parents and trashed = false and name contains '${name.replace(/'/g, "\\'")}'`,
    fields: "files(id,name,mimeType,modifiedTime)",
  });
  console.log(JSON.stringify(res.data.files, null, 2));
}

async function pull(fileId, outPath) {
  if (!fileId || !outPath) usage("pull <fileId> <localPath>");
  const drive = getDrive();
  const meta = await drive.files.get({ fileId, fields: "id,name,mimeType" });
  const mimeType = meta.data.mimeType;

  fs.mkdirSync(path.dirname(outPath), { recursive: true });

  if (mimeType.startsWith("application/vnd.google-apps")) {
    const exportMime = GOOGLE_EXPORT_MIME[mimeType];
    if (!exportMime) {
      console.error(`No export mapping for ${mimeType}. Add one in lib/drive.mjs.`);
      process.exit(1);
    }
    const res = await drive.files.export({ fileId, mimeType: exportMime }, { responseType: "arraybuffer" });
    fs.writeFileSync(outPath, Buffer.from(res.data));
  } else {
    const res = await drive.files.get({ fileId, alt: "media" }, { responseType: "arraybuffer" });
    fs.writeFileSync(outPath, Buffer.from(res.data));
  }

  console.log(`Pulled "${meta.data.name}" (${mimeType}) -> ${outPath}`);
}

async function push(localPath, fileId) {
  if (!localPath || !fileId) usage("push <localPath> <fileId>");
  const drive = getDrive();
  const mimeType = guessMime(localPath);
  const res = await drive.files.update({
    fileId,
    media: { mimeType, body: fs.createReadStream(localPath) },
    fields: "id,name,mimeType,modifiedTime",
  });
  console.log(`Pushed ${localPath} -> "${res.data.name}" (${res.data.id}), updated ${res.data.modifiedTime}`);
}

async function create(localPath, parentId, ...titleParts) {
  if (!localPath || !parentId) usage("create <localPath> <parentFolderId> [title]");
  const title = titleParts.join(" ") || path.basename(localPath);
  const drive = getDrive();
  const mimeType = guessMime(localPath);
  const res = await drive.files.create({
    requestBody: { name: title, parents: [parentId] },
    media: { mimeType, body: fs.createReadStream(localPath) },
    fields: "id,name,webViewLink",
  });
  console.log(`Created "${res.data.name}" (${res.data.id}) -> ${res.data.webViewLink}`);
}

const commands = { list, find, pull, push, create };
const [, , cmd, ...args] = process.argv;
const fn = commands[cmd];
if (!fn) usage();
await fn(...args);
