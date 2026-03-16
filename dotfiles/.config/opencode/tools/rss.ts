import { tool } from "@opencode-ai/plugin"

const FEEDS_DIR = "/root/feeds"

// Cache for feed URLs keyed by collection name
let feedCache: Map<string, string[]> = new Map()

async function fetchFeed(url: string, limit: number): Promise<string> {
  try {
    const response = await fetch(url, {
      headers: {
        "User-Agent": "OpenCode-RSS-Reader/1.0",
        "Accept": "application/rss+xml, application/atom+xml, application/xml, text/xml"
      }
    })
    const text = await response.text()
    const items = parseRSS(text, url)
    const lines: string[] = []
    lines.push(`\n=== ${url} (${Math.min(items.length, limit)} items) ===`)
    for (const item of items.slice(0, limit)) {
      lines.push(`\n- ${item.title}`)
      lines.push(`  ${item.date}`)
      lines.push(`  ${item.link}`)
      if (item.description) {
        lines.push(`  ${item.description.substring(0, 150)}...`)
      }
    }
    return lines.join("\n")
  } catch (error) {
    return `\n=== ${url} ===\nError: ${error instanceof Error ? error.message : "Unknown error"}`
  }
}

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
    const feeds = parseOPML(content)
    
    feedCache.set(key, feeds.map(f => f.url))
    
    results.push({
      key,
      title: titleMatch ? titleMatch[1] : "Untitled",
      description: descMatch ? descMatch[1] : "",
      count: feeds.length
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
    limit: tool.schema.number().optional().describe("Maximum items per feed (default: all)")
  },
  async execute(args, context) {
    // Default to 9999 (essentially unlimited) instead of 10
    const limit = args.limit || 9999
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
      
      // Fetch all feeds in parallel
      const fetched = await Promise.all(urls.map(url => fetchFeed(url, limit)))
      return fetched.join("\n")
    } catch (error) {
      return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
    }
  }
})

function parseOPML(xml: string): { name: string; url: string; description: string }[] {
  const feeds: { name: string; url: string; description: string }[] = []
  
  // Match outline elements with xmlUrl
  const regex = /<outline([^>]*)>/g
  let match
  while ((match = regex.exec(xml)) !== null) {
    const attrs = match[1]
    const urlMatch = attrs.match(/xmlUrl="([^"]*)"/)
    const textMatch = attrs.match(/text="([^"]*)"/)
    const descMatch = attrs.match(/description="([^"]*)"/)
    
    if (urlMatch && urlMatch[1]) {
      feeds.push({
        url: urlMatch[1],
        name: textMatch ? textMatch[1] : "Untitled",
        description: descMatch ? descMatch[1] : ""
      })
    }
  }
  
  return feeds
}

function parseRSS(xml: string, source: string): { title: string; date: string; link: string; description: string }[] {
  const items: { title: string; date: string; link: string; description: string }[] = []
  const isAtom = xml.includes("<feed")
  
  const entryRegex = isAtom 
    ? /<entry>([\s\S]*?)<\/entry>/g 
    : /<item>([\s\S]*?)<\/item>/g
    
  let match
  while ((match = entryRegex.exec(xml)) !== null) {
    const entry = match[1]
    const title = entry.match(/<title[^>]*>([\s\S]*?)<\/title>/)?.[1] || ""
    const link = entry.match(/<link[^>]*href="([^"]*)"/)?.[1] || 
                 entry.match(/<link>([\s\S]*?)<\/link>/)?.[1] || ""
    const date = entry.match(/<(published|updated|pubDate)>([\s\S]*?)<\/\1>/)?.[2] || ""
    const desc = entry.match(/<(summary|description|content)([^>]*)>([\s\S]*?)<\/\1>/)?.[3] || ""
    
    items.push({
      title: title.replace(/<!\[CDATA\[|\]\]>/g, "").trim(),
      date: date.trim(),
      link,
      description: desc.replace(/<[^>]+>/g, "").trim()
    })
  }
  
  return items
}
