import { tool } from "@opencode-ai/plugin"

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

            const text = await Bun.$`pdftotext -layout ${path} -`.text();

            if (!text.trim()) return "Error: Could not extract text"

            return text
        } catch (error) {
            return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
        }
    }
})

// === TOOL: library_download ===
export const library_download = tool({
    description: "Download a file and save to the library (converts HTML to PDF, keeps other formats as-is)",
    name: "Library Download",
    args: {
        url: tool.schema.string().describe("URL to download (HTTP/HTTPS)"),
        filename: tool.schema.string().describe("Filename to save as (without extension)"),
        directory: tool.schema.string().optional().describe("Subdirectory in library (e.g., 'References', 'Articles'). Defaults to 'References'")
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
})

