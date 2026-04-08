import { tool } from "@opencode-ai/plugin"

const REFERENCES_DIR = "References"
const REFERENCES_BIB = `${REFERENCES_DIR}/_references.bib`

// Normalize BibTeX key to lastname_firstauthor_year format
function normalizeBibtexKey(bibtex: string): { key: string; bibtex: string } {
  // Extract author (last name of first author)
  const authorMatch = bibtex.match(/author\s*=\s*\{([^}]+)\}/)
  let author = ""
  if (authorMatch) {
    const firstAuthor = authorMatch[1].split(" and ")[0]
    author = firstAuthor.split(",")[0].split(" ")[0].toLowerCase().replace(/[^a-z]/g, "")
  }
  
  // Extract year
  const yearMatch = bibtex.match(/year\s*=\s*\{?(\d{4})\}?/)
  const year = yearMatch ? yearMatch[1] : ""
  
  // Build new key
  let newKey = author + year
  if (!newKey) {
    const oldKey = bibtex.match(/@\w+\{([^,]+),/)?.[1] || "unknown"
    newKey = oldKey.toLowerCase().replace(/[^a-z0-9]/g, "").slice(0, 8)
  }
  
  // Rename the entry key
  const normalizedBibtex = bibtex.replace(
    /^@\w+\{[^,]+,/m,
    `@misc{${newKey},`
  )
  
  return { key: newKey, bibtex: normalizedBibtex }
}

// === TOOL: pdf_read ===
export const pdf_read = tool({
  description: "Extract text from a PDF file using pdftotext",
  name: "PDF read",
  args: {
    path: tool.schema.string().describe("Path to PDF file")
  },
  async execute(args, context) {
    const path = args.path?.trim()
    if (!path) return "Error: No path provided"
    
    try {
      const file = Bun.file(path)
      if (!await file.exists()) return `Error: File not found: ${path}`
      
      const text = await Bun.spawn(["pdftotext", "-layout", path, "-"]).text()
      if (!text.trim()) return "Error: Could not extract text"
      
      // Truncate if too long
      const maxLen = 10000
      if (text.length > maxLen) {
        return text.slice(0, maxLen) + "\n\n[... truncated ...]"
      }
      return text
    } catch (error) {
      return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
    }
  }
})

// === TOOL: references_add ===
export const references_add = tool({
  description: "Add a DOI or arXiv ID to References/_to_read.txt (prepends to top)",
  name: "References add",
  args: {
    identifier: tool.schema.string().describe("DOI or arXiv ID to add")
  },
  async execute(args, context) {
    const id = args.identifier?.trim()
    if (!id) return "Error: No identifier provided"
    
    const isValid = id.match(/^https:\/\/doi\.org\//) || 
                   id.match(/^https:\/\/arxiv\.org\//) ||
                   id.match(/^\d{4}\.\d{4,5}$/)
    if (!isValid) {
      return "Error: Invalid format. Use DOI URL, arXiv URL, or arXiv ID"
    }
    
    try {
      const file = `${REFERENCES_DIR}/_to_read.txt`
      const existing = await Bun.file(file).exists() ? await Bun.file(file).text() : ""
      const newContent = id + "\n" + existing
      await Bun.write(file, newContent)
      
      return `Added to _to_read.txt: ${id}`
    } catch (error) {
      return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
    }
  }
})

// === TOOL: references_bib ===
export const references_bib = tool({
  description: "Add BibTeX with summary as abstract to _references.bib (prepends to top)",
  name: "References bib",
  args: {
    bibtex: tool.schema.string().describe("Raw BibTeX entry"),
    summary: tool.schema.string().optional().describe("Summary to add as abstract field")
  },
  async execute(args, context) {
    const bibtex = args.bibtex
    const summary = args.summary
    if (!bibtex) return "Error: No BibTeX provided"
    
    try {
      const { key, bibtex: normalized } = normalizeBibtexKey(bibtex)
      
      // Add summary as abstract if provided
      let finalBibtex = normalized
      if (summary) {
        // Escape braces in summary
        const escapedSummary = summary.replace(/}/g, "\\}").replace(/{/g, "\\{")
        // Check if abstract already exists, if not add it
        if (!normalized.includes("abstract")) {
          finalBibtex = normalized.trim().slice(0, -1) + `,\n  abstract = {${escapedSummary}}\n}`
        }
      }
      
      const file = REFERENCES_BIB
      const existing = await Bun.file(file).exists() ? await Bun.file(file).text() : ""
      const newContent = finalBibtex + "\n" + existing
      await Bun.write(file, newContent)
      
      return `Added: ${key}`
    } catch (error) {
      return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
    }
  }
})