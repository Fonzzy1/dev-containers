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

