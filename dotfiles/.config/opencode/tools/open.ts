import { tool } from "@opencode-ai/plugin"

export const open = tool({
    description: "Open a URL or file in the default application using xdg-open",
    name: "Open",
    args: {
        target: tool.schema.string().describe("URL or file path to open")
    },
    async execute(args, context) {
        const target = args.target?.trim()
        if (!target) return "Error: No target provided"
        
        try {
            await Bun.spawn(["xdg-open", target])
            return `Opened: ${target}`
        } catch (error) {
            return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
        }
    }
})