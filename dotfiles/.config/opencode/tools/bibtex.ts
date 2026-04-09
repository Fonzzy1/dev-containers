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

        let bibtex = ""
        let url = ""
        const maxRetries = 3

        // Helper to extract DOI from various URL formats
        function extractDoi(input: string): string | null {
            // Handle bare DOI (e.g., 10.1080/1369118X.2026.2652510)
            if (/^10\.\d{4,}\/[^\s]+$/.test(input)) {
                return input
            }

            // Handle various DOI URL formats
            const doiPatterns = [
                /https?:\/\/doi\.org\/(.+)/i,
                /https?:\/\/dx\.doi\.org\/(.+)/i,
                /https?:\/\/doi\.org\/(.+)/i,
                /doi:\s*(10\.\d{4,}\/[^\s]+)/i
            ]
            for (const pattern of doiPatterns) {
                const match = input.match(pattern)
                if (match) return match[1]
            }
            return null
        }

        try {
            if (id.startsWith("https://arxiv.org/") || id.startsWith("http://arxiv.org/") || id.match(/^\d{4}\.\d{5}$/)) {
                // arXiv URL or ID
                const arxiv_id = id.match(/(\d{4}\.\d{5})/)?.[1] || id
                url = `https://arxiv.org/bibtex/${arxiv_id}`
                bibtex = await Bun.$`curl -sL -A "Mozilla/5.0 (compatible; OpenCode-BibTeX/1.0)" "${url}"`.text()
            } else {
                // Assume DOI (try to extract DOI from various formats)
                const doi = extractDoi(id)
                if (!doi) {
                    return `Error: Not a recognized DOI or arXiv link/ID: ${id}\nSupported formats:\n  - DOI: https://doi.org/..., http://dx.doi.org/..., or bare DOI (10.xxxx/...)\n  - arXiv: https://arxiv.org/abs/... or 2401.12345`
                }
                url = `https://doi.org/${doi}`

                // Try multiple times with retry logic
                for (let attempt = 1; attempt <= maxRetries; attempt++) {
                    bibtex = await Bun.$`curl -sL -A "Mozilla/5.0 (compatible; OpenCode-BibTeX/1.0)" -H "Accept: application/x-bibtex" "${url}"`.text()

                    // Check if we got a valid response (not an error page or empty)
                    if (bibtex.length > 0 && !bibtex.includes("<html") && !bibtex.includes("<!DOCTYPE")) {
                        break
                    }

                    // Wait before retry (exponential backoff)
                    if (attempt < maxRetries) {
                        await new Promise(r => setTimeout(r, 500 * attempt))
                    }
                }
            }

            // Validate response
            if (!bibtex || bibtex.trim().length === 0) {
                return `Error: No BibTeX found for ${id}\nURL: ${url}\nThe identifier may be invalid or the service may be temporarily unavailable.`
            }

            // Check for error indicators in response
            if (bibtex.includes("<html") || bibtex.includes("<!DOCTYPE") || bibtex.includes("Error") || bibtex.includes("Not Found")) {
                return `Error: Failed to fetch BibTeX for ${id}\nURL: ${url}\nResponse: ${bibtex.slice(0, 500)}`
            }

            return "=== BibTeX ===\n" + bibtex
        } catch (error) {
            return `Error: ${error instanceof Error ? error.message : "Unknown error"}\nURL attempted: ${url}`
        }
    }
})
