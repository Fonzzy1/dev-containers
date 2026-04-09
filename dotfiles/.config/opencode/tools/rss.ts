import { tool } from "@opencode-ai/plugin"

const FEEDS_DIR = "/root/feeds"
const PYTHON_FEED_PARSER = "/scripts/feed_parser.py"

// Cache for feed URLs keyed by collection name
let feedCache: Map<string, string[]> = new Map()

async function loadFeedsDir(): Promise<{ key: string; title: string; description: string; count: number }[]> {
    const results: { key: string; title: string; description: string; count: number }[] = []

    const files = await Bun.$`ls ${FEEDS_DIR}/*.opml`.text()
    const opmlFiles = files.split("\n").filter(f => f.endsWith(".opml"))

    for (const opmlFile of opmlFiles) {
        if (!opmlFile.trim()) continue

        const key = opmlFile.trim().split("/").pop()?.replace(".opml", "") || ""
        const content = await Bun.file(opmlFile.trim()).text()

        const titleMatch = content.match(/<title>([^<]*)<\/title>/i)
        const descMatch = content.match(/<description>([^<]*)<\/description>/i)

        // Simple regex-based OPML parsing to extract xmlUrl attributes
        const urlMatches = content.matchAll(/xmlUrl="([^"]+)"/g)
        const urls: string[] = []
        for (const match of urlMatches) {
            urls.push(match[1])
        }

        feedCache.set(key, urls)

        results.push({
            key,
            title: titleMatch ? titleMatch[1] : "Untitled",
            description: descMatch ? descMatch[1] : "",
            count: urls.length
        })
    }

    return results
}

export const rss_list = tool({
    description: "List available RSS feed collections",
    name: "RSS list",
    args: {},
    async execute(args, context) {
        try {
            const feeds = await loadFeedsDir()

            if (feeds.length === 0) {
                return "No feed collections found"
            }

            const lines: string[] = ["Available feed collections:\n"]
            for (const feed of feeds) {
                lines.push(`[${feed.key}]`)
                lines.push(`  ${feed.title}`)
                if (feed.description) {
                    lines.push(`  ${feed.description}`)
                }
                lines.push(`  ${feed.count} feeds`)
                lines.push("")
            }

            return lines.join("\n")
        } catch (error) {
            return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
        }
    }
})

export const rss_read = tool({
    description: "Fetch and read an RSS feed collection by key",
    name: "RSS read",
    args: {
        key: tool.schema.string().describe("Key of the feed collection to fetch (e.g., news, academic, arxiv, pods)"),
        since: tool.schema.string().optional().describe("Only return items published on or after this date (ISO format, e.g., 2024-01-01)")
    },
    async execute(args, context) {
        const sinceDate = args.since || null
        const key = args.key?.trim().toLowerCase()

        if (!key) {
            return "Error: No key provided. Run 'rss list' to see available collections."
        }

        try {
            // Load feeds if not cached
            if (feedCache.size === 0) {
                await loadFeedsDir()
            }

            const urls = feedCache.get(key)
            if (!urls) {
                const available = Array.from(feedCache.keys()).join(", ")
                return `Error: Unknown key '${key}'.\nAvailable keys: ${available}`
            }

            if (urls.length === 0) {
                return `Error: No feeds found for '${key}'`
            }

            const result = await (sinceDate
                ? Bun.$`python3 ${PYTHON_FEED_PARSER} --since ${sinceDate} ${urls}`
                : Bun.$`python3 ${PYTHON_FEED_PARSER} ${urls}`
            ).text()
            return result

        } catch (error) {
            return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
        }
    }
})
