#!/usr/bin/env node

/**
 * Sync content from a personal knowledge wiki into a Quartz site.
 *
 * Usage:
 *   node sync-content.mjs --source external/content --target content
 *
 * What it does:
 *   - Copies only wiki/ pages with publish: true
 *   - Injects title from H1 into frontmatter
 *   - Strips sensitive fields (phone, email, address)
 *   - Builds a homepage with section counts
 *   - NEVER copies sources/ or inbox/
 */

import fs from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const SAFE_KINDS = ["person", "project", "place", "concept", "topic", "map", "period"]
const STRIP_FIELDS = ["phone", "email", "address", "id_number", "passport", "ssn"]
const SECTION_ORDER = ["people", "projects", "places", "concepts", "topics", "maps", "periods"]
const WIKILINK_RE = /\[\[([^\]]+)\]\]/g
const SOURCE_EMBED_RE = /!?\[\[sources\/[^\]|#]+(?:\|[^\]]+)?\]\]/g

function walkMarkdown(dir) {
  const results = []
  if (!fs.existsSync(dir)) return results
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) continue
    const fullPath = path.join(dir, entry.name)
    if (entry.isDirectory()) {
      results.push(...walkMarkdown(fullPath))
    } else if (entry.name.endsWith(".md")) {
      results.push(fullPath)
    }
  }
  return results
}

function emptyDir(dir) {
  fs.rmSync(dir, { recursive: true, force: true })
  fs.mkdirSync(dir, { recursive: true })
}

function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---\n/)
  if (!match) return { frontmatter: {}, body: content, raw: "" }
  try {
    const fm = {}
    const lines = match[1].split("\n")
    for (const line of lines) {
      const colonIdx = line.indexOf(":")
      if (colonIdx > 0) {
        const key = line.slice(0, colonIdx).trim()
        const val = line.slice(colonIdx + 1).trim()
        fm[key] = val
      }
    }
    return { frontmatter: fm, body: content.slice(match[0].length), raw: match[1] }
  } catch {
    return { frontmatter: {}, body: content, raw: "" }
  }
}

function serializeFrontmatter(fm) {
  const lines = Object.entries(fm).map(([k, v]) => `${k}: ${v}`)
  return `---\n${lines.join("\n")}\n---\n`
}

function injectTitle(content) {
  const h1Match = content.match(/^#\s+(.+)$/m)
  if (!h1Match) return content

  const h1Title = h1Match[1].trim()
  const quotedTitle = JSON.stringify(h1Title)

  const fmMatch = content.match(/^(---\n)([\s\S]*?)(---\n)/)
  if (!fmMatch) {
    return `---\ntitle: ${quotedTitle}\n---\n\n${content}`
  }

  if (/^title:/m.test(fmMatch[2])) return content

  const newFm = fmMatch[1] + `title: ${quotedTitle}\n` + fmMatch[2] + fmMatch[3]
  return newFm + content.slice(fmMatch[0].length)
}

function sanitize(content) {
  // Strip source embeds (e.g., ![[sources/identity/...]])
  return content.replace(SOURCE_EMBED_RE, "")
}

function shouldPublish(fm) {
  if (fm.publish !== "true" && fm.publish !== true) return false
  if (!SAFE_KINDS.includes(fm.kind)) return false
  return true
}

function stripSensitive(fm) {
  for (const field of STRIP_FIELDS) {
    delete fm[field]
  }
  return fm
}

function toTitle(slug) {
  return slug.split("-").map(p => p.charAt(0).toUpperCase() + p.slice(1)).join(" ")
}

function buildHomepage(sections) {
  const now = new Date()
  const y = now.getFullYear()
  const m = String(now.getMonth() + 1).padStart(2, "0")
  const d = String(now.getDate()).padStart(2, "0")

  const sectionLines = sections
    .map(s => `- [[${s.slug}/|${s.title}]] (${s.count})`)
    .join("\n")

  const total = sections.reduce((sum, s) => sum + s.count, 0)

  return `---
title: Wiki
updated: ${y}-${m}-${d}
---

# Wiki

A personal knowledge base.

*${total} pages across ${sections.length} sections.*

## Sections

${sectionLines}
`
}

// --- Main ---

const args = process.argv.slice(2)
let sourceDir = "external/content"
let targetDir = "content"

for (let i = 0; i < args.length; i++) {
  if (args[i] === "--source" && args[i + 1]) sourceDir = args[i + 1]
  if (args[i] === "--target" && args[i + 1]) targetDir = args[i + 1]
}

const wikiDir = path.join(sourceDir, "wiki")
if (!fs.existsSync(wikiDir)) {
  console.error(`Wiki directory not found: ${wikiDir}`)
  process.exit(1)
}

emptyDir(targetDir)

const sections = {}
let totalPublished = 0

for (const filePath of walkMarkdown(wikiDir)) {
  const relPath = path.relative(wikiDir, filePath)
  const content = fs.readFileSync(filePath, "utf-8")

  const { frontmatter, body } = parseFrontmatter(content)

  if (!shouldPublish(frontmatter)) continue

  stripSensitive(frontmatter)
  frontmatter.publish = undefined

  let newContent = injectTitle(content)
  newContent = sanitize(newContent)

  const targetPath = path.join(targetDir, relPath)
  fs.mkdirSync(path.dirname(targetPath), { recursive: true })
  fs.writeFileSync(targetPath, newContent)

  const section = relPath.split(path.sep)[0]
  sections[section] = (sections[section] || 0) + 1
  totalPublished++
}

// Build homepage
const sortedSections = SECTION_ORDER
  .filter(s => sections[s])
  .map(s => ({ slug: s, title: toTitle(s), count: sections[s] }))

const homepage = buildHomepage(sortedSections)
fs.writeFileSync(path.join(targetDir, "index.md"), homepage)

console.log(`Synced ${totalPublished} pages to ${targetDir}`)
for (const s of sortedSections) {
  console.log(`  ${s.slug}: ${s.count}`)
}
