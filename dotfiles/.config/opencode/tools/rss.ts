import { tool } from "@opencode-ai/plugin"

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

async function expandOPML(source: string): Promise<string[]> {
  const expanded = source.replace(/^~/, process.env.HOME || "")
  let text: string
  if (source.startsWith("http")) {
    const response = await fetch(source, {
      headers: { "User-Agent": "OpenCode-RSS-Reader/1.0" }
    })
    text = await response.text()
  } else {
    text = await Bun.file(expanded).text()
  }
  return parseOPML(text).map(f => f.url)
}

export const rss_read = tool({
  description: "Fetch and read RSS/Atom feeds from URLs or OPML files",
  args: {
    source: tool.schema.string().describe("RSS/Atom feed URLs or OPML file paths (comma-separated)"),
    limit: tool.schema.number().optional().describe("Maximum items per feed (default: 200)")
  },
  async execute(args, context) {
    const limit = args.limit || 200
    const sources = args.source.split(",").map(s => s.trim()).filter(s => s)

    if (sources.length === 0) {
      return "Error: No source provided"
    }

    // Resolve all sources — expand OPML files into their feed URLs
    const feedUrls: string[] = []
    for (const source of sources) {
      const expanded = source.replace(/^~/, process.env.HOME || "")
      const isOpml = source.endsWith(".opml") || (!source.startsWith("http") && expanded.endsWith(".opml"))
      if (isOpml) {
        try {
          const urls = await expandOPML(source)
          feedUrls.push(...urls)
        } catch (error) {
          return `Error expanding OPML ${source}: ${error instanceof Error ? error.message : "Unknown error"}`
        }
      } else if (source.startsWith("http")) {
        // Peek: might be an OPML served over HTTP without .opml extension
        try {
          const response = await fetch(source, {
            headers: { "User-Agent": "OpenCode-RSS-Reader/1.0" }
          })
          const text = await response.text()
          if (text.includes("<opml")) {
            const urls = parseOPML(text).map(f => f.url)
            feedUrls.push(...urls)
          } else {
            feedUrls.push(source)
          }
        } catch {
          feedUrls.push(source)
        }
      } else {
        feedUrls.push(source)
      }
    }

    // Fetch all feeds in parallel
    const fetched = await Promise.all(feedUrls.map(url => fetchFeed(url, limit)))
    return fetched.join("\n")
  }
})

export const rss_list = tool({
  description: "List available RSS feeds from OPML files with descriptions",
  args: {
    source: tool.schema.string().optional().describe("OPML file path (default: /root/feeds/)")
  },
  async execute(args, context) {
    const basePath = args.source?.replace(/^~/, process.env.HOME || "") 
      || "/root/feeds"
    
    const results: string[] = []
    
    try {
      // Try to read as directory
      const feedsDir = basePath
      const dir = await Bun.file(feedsDir).exists()
      
      if (dir) {
        // It's a directory - list all OPML files
        const files = await Bun.$`ls ${feedsDir}/*.opml`.text()
        const opmlFiles = files.split("\n").filter(f => f.endsWith(".opml"))
        
        for (const opmlFile of opmlFiles) {
          if (!opmlFile.trim()) continue
          const content = await Bun.file(opmlFile.trim()).text()
          const opmlTitle = content.match(/<title>([^<]*)<\/title>/i)?.[1] || "Untitled"
          const feeds = parseOPML(content)
          
          results.push(`\n=== ${opmlTitle} (${opmlFile.trim().split("/").pop()}) ===`)
          results.push(`${feeds.length} feeds:\n`)
          for (const feed of feeds) {
            results.push(`- ${feed.name}`)
            if (feed.description) {
              results.push(`  ${feed.description}`)
            }
            results.push(`  ${feed.url}`)
          }
        }
      } else {
        // It's a single file
        const content = await Bun.file(basePath).text()
        const opmlTitle = content.match(/<title>([^<]*)<\/title>/i)?.[1] || "Untitled"
        const feeds = parseOPML(content)
        
        results.push(`=== ${opmlTitle} ===`)
        results.push(`${feeds.length} feeds:\n`)
        for (const feed of feeds) {
          results.push(`- ${feed.name}`)
          if (feed.description) {
            results.push(`  ${feed.description}`)
          }
          results.push(`  ${feed.url}`)
        }
      }
    } catch (error) {
      return `Error: ${error instanceof Error ? error.message : "Unknown error"}`
    }
    
    return results.join("\n") || "No OPML files found"
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
