import { tool } from "@opencode-ai/plugin"

export const bibtex_fetch = tool({
  description: "Fetch BibTeX entry from DOI or arXiv ID. Accepts DOI URLs (https://doi.org/...), arXiv URLs (https://arxiv.org/abs/...), or bare arXiv IDs (e.g., 2401.12345)",
  name: "BibTeX fetch",
  args: {
    identifier: tool.schema.string().describe("DOI or arXiv identifier to fetch BibTeX for")
  },
  async execute(args, context) {
    const id = args.identifier?.trim()
    
    if (!id) {
      return "Error: No identifier provided. Please provide a DOI URL, arXiv URL, or arXiv ID."
    }
    
    let bibtex: string[] = []
    
    try {
      if (id.match("^https://doi%.org/")) {
        // DOI URL
        const doi = id.replace("^https://doi%.org/", "")
        bibtex = await Bun.$`curl -sL -H "Accept: application/x-bibtex" "https://doi.org/${doi}"`.text().then(t => t.split("\n").filter(l => l.trim()))
        
      } else if (id.match("^https://arxiv%.org/abs/") || id.match("^%d%d%d%d%.%d%d%d%d%d$")) {
        // arXiv URL or ID
        const arxiv_id = id.match("(%d%d%d%d%.%d%d%d%d%d)")?.[1] || id
        bibtex = await Bun.$`curl -sL "https://arxiv.org/bibtex/${arxiv_id}"`.text().then(t => t.split("\n").filter(l => l.trim()))
        
      } else {
        return `Error: Not a recognized DOI or arXiv link/ID: ${id}\nSupported formats:\n  - DOI: https://doi.org/... or 10.1234/...\n  - arXiv: https://arxiv.org/abs/... or 2401.12345`
      }
      
      if (bibtex.length === 0 || bibtex.every(l => !l.trim())) {
        return `Error: Failed to fetch BibTeX for: ${id}`
      }
      
      return "=== BibTeX ===\n" + bibtex.join("\n")
    } catch (error) {
      return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
    }
  }
})