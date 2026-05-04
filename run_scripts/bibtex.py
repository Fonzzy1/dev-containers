#!/usr/bin/env python3
import re
import subprocess
import sys
from urllib.parse import urlparse
import requests
from newspaper import Config, Article

DOI_URL_RE = re.compile(r"^https?://doi\.org/(.+)$", re.I)
ARXIV_URL_RE = re.compile(
    r"^https?://arxiv\.org/abs/([0-9]{4}\.[0-9]{4,5})(v\d+)?$", re.I
)
ARXIV_ID_RE = re.compile(r"^([0-9]{4}\.[0-9]{4,5})(v\d+)?$", re.I)
BIBTEX_LIKE_RE = re.compile(r"@\w+\s*\{", re.I)


def make_newspaper_config():
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"
    config = Config()
    config.browser_user_agent = user_agent
    return config


def fetch_url_text(url, headers=None, timeout=20):
    resp = requests.get(
        url, headers=headers or {}, timeout=timeout, allow_redirects=True
    )
    resp.raise_for_status()
    return resp.text


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
    return text.replace("\\", "\\\\").replace("{", "\\{").replace("}", "\\}")


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

    author_field = " and ".join(authors) if authors else "Unknown Author"
    bibkey = make_bibtex_key(authors, year, title)

    fields = {
        "title": escape_bibtex(title),
        "author": escape_bibtex(author_field),
        "year": str(year) if year else "",
        "month": str(month) if month else "",
        "day": str(day) if day else "",
        "date": (
            f"{year}-{month:02d}-{day:02d}" if year and month and day else ""
        ),
        "journal": escape_bibtex(journal),
        "url": url,
    }

    bib_lines = [f"@article{{{bibkey},"]
    for k, v in fields.items():
        if v:
            bib_lines.append(f"  {k} = {{{v}}},")
    bib_lines.append("}")
    return "\n".join(bib_lines)


def resolve_input_to_bibtex(word):
    word = word.strip()

    if DOI_URL_RE.match(word):
        return fetch_doi_bibtex(word)

    if ARXIV_URL_RE.match(word) or ARXIV_ID_RE.match(word):
        return fetch_arxiv_bibtex(word)

    if word.startswith("http://") or word.startswith("https://"):
        text = fetch_url_text(word)
        if looks_like_bibtex(text):
            return text.strip()
        return article_to_bibtex(word)

    raise ValueError(f"Not a recognized DOI, arXiv link/ID, or URL: {word}")


def main():
    if len(sys.argv) < 2:
        print(
            "Usage: to_bibtex.py <doi-url|arxiv-url|arxiv-id|url>",
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
