import { z } from "zod"
import * as fs from "fs"
import * as path from "path"

const SESSION_REGISTRY = "/tmp/opencode_session_opened.json"

function getSessionRegistry(): Set<string> {
    try {
        if (fs.existsSync(SESSION_REGISTRY)) {
            const data = JSON.parse(fs.readFileSync(SESSION_REGISTRY, "utf-8"))
            return new Set(data.opened || [])
        }
    } catch (e) {
        // If file is corrupted or doesn't exist, start fresh
    }
    return new Set()
}

function saveSessionRegistry(opened: Set<string>) {
    try {
        fs.writeFileSync(SESSION_REGISTRY, JSON.stringify({ opened: Array.from(opened) }, null, 2))
    } catch (e) {
        console.error("Failed to save session registry:", e)
    }
}

function isUrl(target: string): boolean {
    return target.startsWith("http://") || target.startsWith("https://") || target.startsWith("file://")
}

export const open = {
    description: "Open a URL or file in the default application using xdg-open. Tracks opened files per session and skips re-opens unless it's a URL.",
    name: "Open",
    args: {
        target: z.string().describe("URL or file path to open")
    },
    async execute(args, context) {
        const target = args.target?.trim()
        if (!target) return "Error: No target provided"

        const isUrlTarget = isUrl(target)
        const registry = getSessionRegistry()

        // Skip re-opening files (but always open URLs)
        if (!isUrlTarget && registry.has(target)) {
            return `Already opened this session: ${target}`
        }

        try {
            await Bun.spawn(["xdg-open", target])

            // Track this file in the session registry (only for non-URLs)
            if (!isUrlTarget) {
                registry.add(target)
                saveSessionRegistry(registry)
            }

            return `Opened: ${target}`
        } catch (error) {
            return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
        }
    }
}
