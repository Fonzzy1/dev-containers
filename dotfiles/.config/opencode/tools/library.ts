import { z } from "zod"
import * as fs from "fs"
import * as path from "path"

const DEFAULT_BIB_PATH = "References/_references.bib"

// === TOOL: pdf_read ===
export const pdf_read = {
    description: "Extract text from a PDF file using pdftotext",
    name: "PDF read",
    args: {
        path: z.string().describe("Path to PDF file")
    },
    async execute(args, context) {
        const path = args.path?.trim()
        if (!path) return "Error: No path provided"

        try {
            const file = Bun.file(path)
            if (!await file.exists()) return `Error: File not found: ${path}`

            const text = await Bun.$`pdftotext -layout ${path} -`.text();

            if (!text.trim()) return "Error: Could not extract text"

            return text
        } catch (error) {
            return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
        }
    }
}

// === TOOL: library_download ===
export const download = {
    description: "Download a file and save to the library (converts HTML to PDF, keeps other formats as-is)",
    name: "Library Download",
    args: {
        url: z.string().describe("URL to download (HTTP/HTTPS)"),
        filename: z.string().describe("Filename to save as (without extension)"),
        directory: z.string().optional().describe("Subdirectory in library (e.g., 'References', 'Articles'). Defaults to 'References'")
    },
    async execute(args, context) {
        const url = args.url?.trim()
        const filename = args.filename?.trim()
        const directory = (args.directory?.trim() || "References").replace(/^\/+|\/+$/g, "")

        // Validation
        if (!url) return "Error: No URL provided"
        if (!filename) return "Error: No filename provided"
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
            return "Error: URL must start with http:// or https://"
        }

        try {
            // Ensure directory exists
            const dir = `${context.worktree}/${directory}`
            await Bun.$`mkdir -p ${dir}`.quiet()

            // Download the file to a temporary location first
            const tempPath = `${dir}/.${filename}.tmp`
            await Bun.$`curl -s -L -o ${tempPath} ${url}`.quiet()

            // Check if file was downloaded
            const tempFile = Bun.file(tempPath)
            if (!await tempFile.exists()) {
                return `Error: Failed to download from ${url}`
            }

            // Determine content type by checking file headers
            const buffer = await tempFile.arrayBuffer()
            const bytes = new Uint8Array(buffer)

            // Check for HTML content (look for HTML markers in first 1KB)
            const headerText = new TextDecoder().decode(bytes.slice(0, 1024)).toLowerCase()
            const isHtml = headerText.includes('<!doctype html') ||
                headerText.includes('<html') ||
                headerText.includes('content-type: text/html')

            let finalPath: string

            if (isHtml) {
                // Convert HTML to PDF
                finalPath = `${dir}/${filename}.pdf`
                try {
                    await Bun.$`wkhtmltopdf ${tempPath} ${finalPath}`.quiet()
                } catch {
                    return `Error: Failed to convert HTML to PDF`
                }
            } else {
                // Keep original format - determine extension from URL or content
                let extension = "bin" // default

                // Try to get extension from URL
                const urlPath = new URL(url).pathname
                const urlExt = urlPath.split('.').pop()?.toLowerCase()
                if (urlExt && urlExt.length < 10) { // reasonable extension length
                    extension = urlExt
                } else {
                    // Try to detect from magic bytes
                    if (bytes[0] === 0xFF && bytes[1] === 0xD8) extension = "jpg"
                    else if (bytes[0] === 0x89 && bytes[1] === 0x50) extension = "png"
                    else if (bytes[0] === 0x47 && bytes[1] === 0x49) extension = "gif"
                    else if (bytes[0] === 0x25 && bytes[1] === 0x50) extension = "pdf"
                    else if (bytes[0] === 0x7B) extension = "json" // starts with {
                    else if (bytes[0] === 0x3C) extension = "xml" // starts with <
                }

                finalPath = `${dir}/${filename}.${extension}`
            }

            // Move temp file to final location
            await Bun.$`mv ${tempPath} ${finalPath}`.quiet()

            // Verify file was created
            const finalFile = Bun.file(finalPath)
            if (!await finalFile.exists()) {
                return `Error: Failed to save file at ${finalPath}`
            }

            const stats = await finalFile.stat()
            return `Successfully downloaded and saved to ${finalPath} (${Math.round(stats.size / 1024)} KB)`
        } catch (error) {
            return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
        }
    }
}

// === TOOL: library_bibtex_add ===
export const bibtex_add = {
    description: "Append a BibTeX entry to a .bib file and run bibtex-tidy for formatting",
    name: "BibTeX add",
    args: {
        entry: z.string().describe("The BibTeX entry to append (e.g., @article{key, title={...}, ...})"),
        bibpath: z.string().optional().describe("Path to the .bib file. Defaults to 'References/_references.bib' if not provided")
    },
    async execute(args, context) {
        const entry = args.entry?.trim()
        let bibpath = args.bibpath?.trim()

        if (!entry) {
            return "Error: No BibTeX entry provided. Please provide a BibTeX entry to add."
        }

        // Use default path if not provided
        if (!bibpath) {
            bibpath = DEFAULT_BIB_PATH
        }

        // Ensure path is relative to worktree if not absolute
        const fullPath = path.isAbsolute(bibpath)
            ? bibpath
            : path.join(context.worktree, bibpath)

        try {
            // Ensure the directory exists
            const dir = path.dirname(fullPath)
            await Bun.$`mkdir -p ${dir}`.quiet()

            // Append the entry to the .bib file
            const entryWithNewline = entry.startsWith("\n") ? entry : "\n" + entry
            if (fs.existsSync(fullPath)) {
                fs.appendFileSync(fullPath, entryWithNewline)
            } else {
                // Create new file with entry
                fs.writeFileSync(fullPath, entryWithNewline)
            }


            // Run bibtex-tidy with the specified options
            const result = await Bun.$`bibtex-tidy -m --curly --numeric --align=13 --duplicates=key --no-escape --sort-fields --remove-empty-fields --no-remove-dupe-fields --sort=-year,key ${fullPath}`.text()

            return `Successfully added BibTeX entry to ${bibpath} and formatted with bibtex-tidy.\n\n${result}`
        } catch (error) {
            return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
        }
    }
}

// === TOOL: library_bibtex_fetch ===
export const bibtex_fetch = {
    description: "Fetch BibTeX entry from DOI or arXiv ID. Accepts DOI URLs (https://doi.org/...), arXiv URLs (https://arxiv.org/abs/...), or bare arXiv IDs (e.g., 2401.12345)",
    name: "BibTeX fetch",
    args: {
        identifier: z.string().describe("DOI or arXiv identifier to fetch BibTeX for")
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
}

