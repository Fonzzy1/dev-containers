#!/usr/bin/env python3

"""
pip install feedparser aiohttp python-dateutil
"""

import sys
import asyncio
import aiohttp
import feedparser
import json
import re
import argparse
from html.parser import HTMLParser
from datetime import timezone
from dateutil import parser as date_parser
from zoneinfo import ZoneInfo


def to_melbourne_time(dt):
    melbourne = ZoneInfo("Australia/Melbourne")
    dt_mel = dt.astimezone(melbourne)
    return dt_mel.strftime("%Y-%m-%d %H:%M")


class MLStripper(HTMLParser):
    def __init__(self):
        super().__init__()
        self.fed = []

    def handle_data(self, d):
        self.fed.append(d)

    def get_data(self):
        return "".join(self.fed)


def strip_tags(html):
    s = MLStripper()
    s.feed(html)
    return s.get_data()


def parse_entry_date(entry):
    for date_key in ("updated", "published"):
        if date_key in entry and entry[date_key]:
            try:
                dt = date_parser.parse(entry[date_key])
                if not dt.tzinfo:
                    dt = dt.replace(tzinfo=timezone.utc)
                return dt
            except Exception:
                continue
    return None


def clean(s):
    if not isinstance(s, str):
        s = str(s)
    return re.sub(r"\s+", " ", s).strip()


def get_abstract(entry):
    for key in ("abstract", "summary", "description"):
        if key in entry and entry[key]:
            return strip_tags(entry[key])
    if "content" in entry and entry["content"]:
        return strip_tags(str(entry["content"][0]))
    return ""


async def fetch_feed(session, url):
    try:
        async with session.get(
            url, timeout=aiohttp.ClientTimeout(total=30)
        ) as resp:
            content = await resp.read()
            feed = feedparser.parse(content)

            source_name = clean(feed.feed.get("title", "<Unknown Source>"))
            entries = []

            for entry in feed.entries:
                dt = parse_entry_date(entry)
                if not dt:
                    continue

                entries.append(
                    {
                        "source": source_name,
                        "source_url": url,
                        "title": clean(entry.get("title", "<No Title>")),
                        "link": entry.get("link", ""),
                        "doi": entry.get("doi"),
                        "date": to_melbourne_time(dt),
                        "description": clean(get_abstract(entry)),
                        "sort_dt": dt.isoformat(),
                    }
                )

            return entries

    except Exception as e:
        print(f"Error fetching {url}: {e}", file=sys.stderr)
        return []


async def main(urls, since_date=None):
    all_entries = []

    async with aiohttp.ClientSession() as session:
        tasks = [fetch_feed(session, url) for url in urls]
        results = await asyncio.gather(*tasks)

    for entries in results:
        all_entries.extend(entries)

    if since_date:
        since_dt = date_parser.parse(since_date)
        if not since_dt.tzinfo:
            since_dt = since_dt.replace(tzinfo=timezone.utc)

        filtered = []
        for e in all_entries:
            entry_dt = date_parser.parse(e["sort_dt"])
            if entry_dt >= since_dt:
                filtered.append(e)
        all_entries = filtered

    all_entries.sort(key=lambda e: e["sort_dt"], reverse=True)

    for e in all_entries:
        del e["sort_dt"]

    print(json.dumps(all_entries, ensure_ascii=False))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fetch RSS/Atom feeds")
    parser.add_argument(
        "--since",
        type=str,
        default=None,
        help="Filter items published on or after this date (e.g., 2026-04-02)",
    )
    parser.add_argument("urls", nargs="+", help="Feed URLs to fetch")
    args = parser.parse_args()

    asyncio.run(main(args.urls, args.since))
