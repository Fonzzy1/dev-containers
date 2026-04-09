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

