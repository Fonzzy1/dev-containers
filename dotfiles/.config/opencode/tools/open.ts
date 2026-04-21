import { z } from "zod"


export const open = {
    description: "Open a URL or file in the default application using xdg-open. Tracks opened files per session and skips re-opens unless it's a URL.",
    name: "Open",
    args: {
        target: z.string().describe("URL or file path to open")
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
}
