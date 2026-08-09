#!/usr/bin/env node

import fs from "node:fs"
import path from "node:path"

const [skillDir] = process.argv.slice(2)

if (!skillDir) {
  console.error("Usage: validate-installed-skill.mjs <skill-directory>")
  process.exit(2)
}

const errors = []
const skillFile = path.join(skillDir, "SKILL.md")
const codexFile = path.join(skillDir, "agents", "openai.yaml")

function requireFile(file) {
  try {
    if (!fs.statSync(file).isFile()) {
      errors.push(`Not a regular file: ${file}`)
    }
  } catch {
    errors.push(`Missing file: ${file}`)
  }
}

requireFile(skillFile)
requireFile(codexFile)

if (fs.existsSync(skillFile) && fs.existsSync(codexFile)) {
  const skill = fs.readFileSync(skillFile, "utf8")
  const codex = fs.readFileSync(codexFile, "utf8")
  const frontmatter = skill.match(/^---\n([\s\S]*?)\n---/)
  const userInvoked = frontmatter
    ? /^disable-model-invocation:\s*true\s*$/m.test(frontmatter[1])
    : false
  const codexDisablesImplicit = /^\s*allow_implicit_invocation:\s*false\s*$/m.test(codex)

  if (userInvoked !== codexDisablesImplicit) {
    errors.push(`Invocation metadata disagrees: ${skillDir}`)
  }
}

if (fs.existsSync(skillFile)) {
  const pending = [skillFile]
  const checked = new Set()

  while (pending.length > 0) {
    const file = pending.pop()
    if (checked.has(file)) continue
    checked.add(file)

    const markdown = fs
      .readFileSync(file, "utf8")
      .replace(/^(```|~~~).*?^\1\s*$/gms, "")

    for (const match of markdown.matchAll(/\[[^\]]*\]\(([^)]+)\)/g)) {
      const rawTarget = match[1].trim().replace(/^<|>$/g, "")
      const target = rawTarget.split(/\s+["']/)[0]
      if (!target || target.startsWith("#") || /^[a-z][a-z0-9+.-]*:/i.test(target)) {
        continue
      }

      let decoded
      try {
        decoded = decodeURIComponent(target.split(/[?#]/)[0])
      } catch {
        errors.push(`Invalid encoded pointer in ${file}: ${target}`)
        continue
      }

      const resolved = path.resolve(path.dirname(file), decoded)
      if (decoded && !fs.existsSync(resolved)) {
        errors.push(`Broken pointer in ${file}: ${target}`)
      } else if (resolved.endsWith(".md") && resolved.startsWith(`${skillDir}${path.sep}`)) {
        pending.push(resolved)
      }
    }
  }
}

if (errors.length > 0) {
  for (const error of errors) console.error(error)
  process.exit(1)
}

console.log(`Validated installed skill: ${skillDir}`)
