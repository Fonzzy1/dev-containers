#!/usr/bin/env python3
import json
import re
import sys
from urllib.parse import quote_plus, urlparse

import requests
from newspaper import Config, Article
from openai import OpenAI

DOI_URL_RE = re.compile(r"^https?://doi\.org/(.+)$", re.I)
ARXIV_URL_RE = re.compile(
    r"^https?://arxiv\.org/abs/([0-9]{4}\.[0-9]{4,5})(v\d+)?$", re.I
)
ARXIV_ID_RE = re.compile(r"^([0-9]{4}\.[0-9]{4,5})(v\d+)?$", re.I)
BIBTEX_LIKE_RE = re.compile(r"@\w+\s*\{", re.I)
ISBN_RE = re.compile(r"^(?:97[89][-\s]?)?(?:\d[-\s]?){9}[\dXx]$")


def make_newspaper_config():
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"
    config = Config()
    config.browser_user_agent = user_agent
    return config


def fetch_url_text(url, headers=None, timeout=20):
    resp = requests.get(
        url, headers=headers or {}, timeout=timeout, allow_redirects=True
    )
    resp.raise_for_status()
    return resp.text


def fetch_json(url, headers=None, timeout=20):
    resp = requests.get(
        url, headers=headers or {}, timeout=timeout, allow_redirects=True
    )
    resp.raise_for_status()
    return resp.json()


def fetch_doi_bibtex(doi_or_url):
    doi = doi_or_url
    m = DOI_URL_RE.match(doi_or_url)
    if m:
        doi = m.group(1)

    url = f"https://doi.org/{doi}"
    return fetch_url_text(
        url, headers={"Accept": "application/x-bibtex"}
    ).strip()


def fetch_arxiv_bibtex(arxiv_input):
    arxiv_id = arxiv_input
    m = ARXIV_URL_RE.match(arxiv_input)
    if m:
        arxiv_id = m.group(1)
    else:
        m = ARXIV_ID_RE.match(arxiv_input)
        if m:
            arxiv_id = m.group(1)
        else:
            raise ValueError(f"Not a valid arXiv URL/ID: {arxiv_input}")

    url = f"https://arxiv.org/bibtex/{arxiv_id}"
    text = fetch_url_text(url).strip()

    if not text:
        raise ValueError(f"Empty arXiv BibTeX response for {arxiv_id}")

    return text


def normalize_isbn(isbn):
    return re.sub(r"[^0-9Xx]", "", isbn).upper()


def is_valid_isbn10(isbn):
    if not re.fullmatch(r"\d{9}[0-9X]", isbn):
        return False
    total = 0
    for i, ch in enumerate(isbn):
        value = 10 if ch == "X" else int(ch)
        total += (10 - i) * value
    return total % 11 == 0


def is_valid_isbn13(isbn):
    if not re.fullmatch(r"\d{13}", isbn):
        return False
    total = 0
    for i, ch in enumerate(isbn):
        n = int(ch)
        total += n if i % 2 == 0 else 3 * n
    return total % 10 == 0


def is_isbn(value):
    isbn = normalize_isbn(value)
    return is_valid_isbn10(isbn) or is_valid_isbn13(isbn)


def fetch_isbn_bibtex(isbn_input):
    isbn = normalize_isbn(isbn_input)
    if not is_isbn(isbn):
        raise ValueError(f"Not a valid ISBN: {isbn_input}")

    url = (
        "https://openlibrary.org/api/books"
        f"?bibkeys=ISBN:{quote_plus(isbn)}&format=json&jscmd=data"
    )
    data = fetch_json(url)
    key = f"ISBN:{isbn}"
    book = data.get(key)
    if not book:
        raise ValueError(f"No book metadata found for ISBN {isbn}")

    title = book.get("title") or ""
    subtitle = book.get("subtitle") or ""
    if subtitle:
        title = f"{title}: {subtitle}"

    authors = [
        a.get("name", "").strip()
        for a in book.get("authors", [])
        if a.get("name")
    ]
    publish_date = book.get("publish_date") or ""
    publishers = [
        p.get("name", "").strip()
        for p in book.get("publishers", [])
        if p.get("name")
    ]
    publisher = publishers[0] if publishers else ""

    year = None
    month = None
    day = None

    m = re.search(r"(\d{4})", publish_date)
    if m:
        year = int(m.group(1))

    bibkey = make_bibtex_key(authors, year, title)

    fields = {
        "title": escape_bibtex(title),
        "author": escape_bibtex(
            " and ".join(authors) if authors else "Unknown Author"
        ),
        "year": str(year) if year else "",
        "publisher": escape_bibtex(publisher),
        "isbn": isbn,
    }

    if publish_date:
        fields["note"] = escape_bibtex(f"Published: {publish_date}")

    bib_lines = [f"@book{{{bibkey},"]
    for k, v in fields.items():
        if v:
            bib_lines.append(f"  {k} = {{{v}}},")
    bib_lines.append("}")
    return "\n".join(bib_lines)


def looks_like_bibtex(text):
    return bool(BIBTEX_LIKE_RE.search(text))


def slugify(text):
    text = re.sub(r"[^A-Za-z0-9]+", "_", text or "")
    text = re.sub(r"_+", "_", text).strip("_")
    return text.lower()


def make_bibtex_key(authors, year, title):
    author_part = "unknown"
    if authors:
        first = authors[0]
        last = first.split()[-1]
        author_part = slugify(last) or "unknown"

    year_part = str(year) if year else "nodate"
    return f"{author_part}{year_part}"


def escape_bibtex(text):
    if not text:
        return ""
    return (
        str(text).replace("\\", "\\\\").replace("{", "\\{").replace("}", "\\}")
    )


def build_bibtex_from_metadata(
    url,
    title="",
    authors=None,
    year=None,
    month=None,
    day=None,
    journal=None,
    entry_type="article",
):
    authors = authors or []
    journal = journal or urlparse(url).netloc.replace("www.", "")
    author_field = " and ".join(authors) if authors else "Unknown Author"
    bibkey = make_bibtex_key(authors, year, title)

    fields = {
        "title": escape_bibtex(title),
        "author": escape_bibtex(author_field),
        "year": str(year) if year else "",
        "month": str(month) if month else "",
        "day": str(day) if day else "",
        "date": (
            f"{int(year):04d}-{int(month):02d}-{int(day):02d}"
            if year and month and day
            else ""
        ),
        "url": url,
    }

    if entry_type == "article":
        fields["journal"] = escape_bibtex(journal)
    else:
        fields["howpublished"] = escape_bibtex(journal)

    bib_lines = [f"@{entry_type}{{{bibkey},"]
    for k, v in fields.items():
        if v:
            bib_lines.append(f"  {k} = {{{v}}},")
    bib_lines.append("}")
    return "\n".join(bib_lines)


def article_to_bibtex(url):
    article = Article(url, config=make_newspaper_config())
    article.download()
    article.parse()

    title = article.title or ""
    authors = article.authors or []
    publish_date = article.publish_date
    year = publish_date.year if publish_date else None
    month = publish_date.month if publish_date else None
    day = publish_date.day if publish_date else None
    journal = urlparse(url).netloc.replace("www.", "")

    return build_bibtex_from_metadata(
        url=url,
        title=title,
        authors=authors,
        year=year,
        month=month,
        day=day,
        journal=journal,
        entry_type="article",
    )


def llm_extract_article_metadata_from_html(html, url):
    client = OpenAI()

    html = html[:120000]

    response = client.responses.create(
        model="gpt-4.1-mini",
        input=[
            {
                "role": "system",
                "content": (
                    "Extract bibliographic metadata from webpage HTML. "
                    "This fallback is mainly for webpages and non-standard content, not necessarily news articles. "
                    "Prefer metadata from citation meta tags, JSON-LD, Open Graph tags, document title, bylines, and visible publication/update dates. "
                    "Return only valid JSON matching the schema. "
                    "If a field is unknown, use null for nullable fields and [] for authors."
                ),
            },
            {
                "role": "user",
                "content": f"URL: {url}\n\nHTML:\n{html}",
            },
        ],
        text={
            "format": {
                "type": "json_schema",
                "name": "webpage_metadata",
                "schema": {
                    "type": "object",
                    "additionalProperties": False,
                    "properties": {
                        "title": {"type": "string"},
                        "authors": {
                            "type": "array",
                            "items": {"type": "string"},
                        },
                        "year": {"type": ["integer", "null"]},
                        "month": {"type": ["integer", "null"]},
                        "day": {"type": ["integer", "null"]},
                        "journal": {"type": ["string", "null"]},
                        "doi": {"type": ["string", "null"]},
                        "url": {"type": "string"},
                    },
                    "required": [
                        "title",
                        "authors",
                        "year",
                        "month",
                        "day",
                        "journal",
                        "doi",
                        "url",
                    ],
                },
                "strict": True,
            }
        },
    )

    parsed = json.loads(response.output_text)
    return {
        "title": parsed.get("title") or "",
        "authors": parsed.get("authors") or [],
        "year": parsed.get("year"),
        "month": parsed.get("month"),
        "day": parsed.get("day"),
        "journal": parsed.get("journal")
        or urlparse(url).netloc.replace("www.", ""),
        "doi": parsed.get("doi"),
        "url": parsed.get("url") or url,
    }


def html_to_bibtex_via_llm(url):
    html = fetch_url_text(
        url,
        headers={"User-Agent": make_newspaper_config().browser_user_agent},
    )
    meta = llm_extract_article_metadata_from_html(html, url)

    doi = meta.get("doi")
    if doi:
        try:
            return fetch_doi_bibtex(doi)
        except Exception:
            pass

    return build_bibtex_from_metadata(
        url=meta["url"],
        title=meta["title"],
        authors=meta["authors"],
        year=meta["year"],
        month=meta["month"],
        day=meta["day"],
        journal=meta["journal"],
        entry_type="misc",
    )


def resolve_input_to_bibtex(word):
    word = word.strip()

    if DOI_URL_RE.match(word):
        return fetch_doi_bibtex(word)

    if ARXIV_URL_RE.match(word) or ARXIV_ID_RE.match(word):
        return fetch_arxiv_bibtex(word)

    if is_isbn(word):
        return fetch_isbn_bibtex(word)

    if word.startswith("http://") or word.startswith("https://"):
        try:
            return article_to_bibtex(word)
        except Exception:
            return html_to_bibtex_via_llm(word)

    raise ValueError(
        f"Not a recognized DOI, arXiv link/ID, ISBN, or URL: {word}"
    )


def main():
    if len(sys.argv) < 2:
        print(
            "Usage: bibtex.py <doi-url|arxiv-url|arxiv-id|isbn|url>",
            file=sys.stderr,
        )
        sys.exit(1)

    word = sys.argv[1]
    try:
        print(resolve_input_to_bibtex(word))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
