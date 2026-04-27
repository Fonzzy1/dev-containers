#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys
from typing import List, Set, Optional, Dict, Any

try:
    from openai import OpenAI
except ImportError:
    OpenAI = None


DEFAULT_MODEL = "gpt-5.4-mini"

IDEA_TYPES = [
    "claim",
    "question",
    "task",
    "idea",
    "entity",
    "quote",
    "reference",
    "definition",
    "opinion",
    "reflection",
    "narrative",
    "comparison",
    "general",
    "thesis",
]

APPEND_JSON_SCHEMA = {
    "name": "brainstorm_append_result",
    "strict": True,
    "schema": {
        "type": "object",
        "properties": {
            "title": {"type": "string"},
            "ideaType": {
                "type": "string",
                "enum": IDEA_TYPES,
            },
            "tags": {
                "type": "array",
                "items": {"type": "string"},
            },
            "enrichment": {"type": "string"},
        },
        "required": ["title", "ideaType", "tags", "enrichment"],
        "additionalProperties": False,
    },
}


def read_file(path: str) -> str:
    if not os.path.exists(path):
        return ""
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def append_text(path: str, text: str) -> None:
    dir_name = os.path.dirname(path)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
    if not text.endswith("\n"):
        text += "\n"
    with open(path, "a", encoding="utf-8") as f:
        f.write(text)


def normalize_ws(text: str) -> str:
    return re.sub(r"\s+", " ", text.strip())


def extract_existing_tags(content: str) -> List[str]:
    tags: Set[str] = set()

    for line in content.splitlines():
        bold_tags = re.findall(r"\*\*([^*\n]+)\*\*", line)
        for tag in bold_tags:
            cleaned = normalize_ws(tag).strip(",")
            if cleaned:
                tags.add(cleaned)

    return sorted(tags)


def extract_idea_headers(content: str) -> List[str]:
    headers = []
    for line in content.splitlines():
        if line.startswith("## "):
            headers.append(line[3:].strip())
    return headers


def has_existing_thesis(content: str, thesis_title: str) -> bool:
    pattern = re.escape(f"## [THESIS] {thesis_title.strip()}")
    return re.search(pattern, content, flags=re.MULTILINE) is not None


def extract_json_candidate(content: str) -> Optional[str]:
    fence_match = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", content)
    if fence_match:
        return fence_match.group(1).strip()

    start = content.find("{")
    end = content.rfind("}")
    if start != -1 and end > start:
        return content[start : end + 1].strip()

    return None


def parse_json_response(content: str) -> Dict[str, Any]:
    candidate = extract_json_candidate(content) or content.strip()
    return json.loads(candidate)


def clean_tag(tag: str) -> str:
    return normalize_ws(tag).strip(",").strip()


def format_brainstorm_block(data: Dict[str, Any]) -> str:
    title = normalize_ws(data["title"])
    idea_type = normalize_ws(data["ideaType"]).upper()
    enrichment = data["enrichment"].strip()

    raw_tags = data.get("tags", [])
    tags = [clean_tag(t) for t in raw_tags if clean_tag(t)]

    parts = [f"## [{idea_type}] {title}", ""]

    if tags:
        parts.append(", ".join(f"**{t}**" for t in tags))
        parts.append("")

    parts.append(enrichment)
    parts.append("")
    parts.append("---")

    return "\n".join(parts).strip() + "\n"


def build_append_prompt(idea: str, existing_content: str) -> str:
    existing_tags = extract_existing_tags(existing_content)
    existing_headers = extract_idea_headers(existing_content)

    tags_text = ", ".join(existing_tags) if existing_tags else "(none)"
    headers_text = (
        "\n".join(f"- {h}" for h in existing_headers[-50:])
        if existing_headers
        else "- (none)"
    )

    return f"""You are a brainstorm enrichment assistant.

Your job:
- Convert the user's brainstorm idea into structured JSON.
- Preserve the user's meaning.
- Add useful enrichment, not fluff.
- Return only one JSON object.
- No markdown.
- No code fences.
- No commentary.

Field requirements:
- "title": concise label for the brainstorm entry
- "ideaType": best-fit type from this set:
  {", ".join(IDEA_TYPES)}
- "tags": 0 to 5 short tags
- "enrichment": a short paragraph expanding the idea

Special rule for BibTeX input:
- If the user input is a BibTeX entry, extract its citation key.
- For BibTeX, set:
  - "title" to "@key" where key is the exact BibTeX key
  - "ideaType" to "reference"
- Preserve the BibTeX key exactly.
- Use the BibTeX abstract if present to inform the enrichment.
- If there is no abstract, use only the supported metadata from the BibTeX entry.
- Do not invent claims not supported by the BibTeX.

Formatting target after parsing:
- The final entry will be rendered as: ## [TYPE] title
- ideaType should be suitable for uppercase display in brackets
- Do not include brackets in ideaType

Rules:
- Keep enrichment concise.
- Do not rewrite existing brainstorm content.
- Do not mention that you are returning JSON.
- Prefer existing tags when relevant.
- Avoid inventing specifics unsupported by the user's idea.

Existing tags:
{tags_text}

Existing idea headers:
{headers_text}

User idea:
{idea}
"""


def build_synthesis_prompt(
    content: str, existing_tags: List[str], idea_headers: List[str]
) -> str:
    tags_text = ", ".join(existing_tags) if existing_tags else "(none)"
    headers_text = (
        "\n".join(f"- {h}" for h in idea_headers)
        if idea_headers
        else "- (none)"
    )

    return f"""You are a Brainstorm Synthesizer.

Task:
- Read the brainstorm content.
- Identify 1 to 3 meaningful connections between existing ideas.
- Generate thesis statements grounded only in the existing ideas.
- Do not invent unsupported claims.
- Do not modify prior content.
- Output only the thesis blocks to append.
- Use this exact format for each thesis:

## [THESIS] Synthesized insight connecting ideas

**tag1**, **tag2**

Explanation of how the thesis connects the ideas and what new insight it represents.

**Grounded in:** Idea 1, Idea 2

---

Rules:
- Only synthesize from ideas already in the file.
- Each thesis must connect at least 2 existing ideas.
- Prefer existing tags from the brainstorm when possible.
- Generate 1 to 3 thesis blocks only.
- No code fences.
- No preamble or commentary.

Existing tags:
{tags_text}

Existing idea headers:
{headers_text}

Brainstorm content:
{content[-24000:] if content else "(empty file)"}
"""


def call_llm_structured(prompt: str, model: str) -> Dict[str, Any]:
    if OpenAI is None:
        raise RuntimeError(
            "openai package not installed. Install with: pip install openai"
        )

    client = OpenAI()

    response = client.responses.create(
        model=model,
        input=prompt,
        text={
            "format": {
                "type": "json_schema",
                "name": APPEND_JSON_SCHEMA["name"],
                "schema": APPEND_JSON_SCHEMA["schema"],
                "strict": True,
            }
        },
    )

    text = getattr(response, "output_text", None)
    if text:
        return parse_json_response(text)

    chunks = []
    for item in getattr(response, "output", []):
        for content in getattr(item, "content", []):
            if getattr(content, "type", "") in ("output_text", "text"):
                txt = getattr(content, "text", "")
                if txt:
                    chunks.append(txt)

    raw = "\n".join(chunks).strip()
    if not raw:
        raise RuntimeError("empty model output")

    return parse_json_response(raw)


def call_llm(prompt: str, model: str) -> str:
    if OpenAI is None:
        raise RuntimeError(
            "openai package not installed. Install with: pip install openai"
        )

    client = OpenAI()

    response = client.responses.create(
        model=model,
        input=prompt,
    )

    text = getattr(response, "output_text", None)
    if text:
        return text.strip()

    chunks = []
    for item in getattr(response, "output", []):
        for content in getattr(item, "content", []):
            if getattr(content, "type", "") in ("output_text", "text"):
                txt = getattr(content, "text", "")
                if txt:
                    chunks.append(txt)
    return "\n".join(chunks).strip()


def ensure_separator(existing: str, new_text: str) -> str:
    if not existing:
        return new_text.rstrip() + "\n"

    if existing.endswith("\n\n"):
        return new_text.rstrip() + "\n"
    if existing.endswith("\n"):
        return "\n" + new_text.rstrip() + "\n"
    return "\n\n" + new_text.rstrip() + "\n"


def dedupe_theses(existing_content: str, generated_text: str) -> str:
    if not generated_text.strip():
        return ""

    blocks = re.split(
        r"(?=^## \[THESIS\] )", generated_text, flags=re.MULTILINE
    )
    kept = []

    for block in blocks:
        stripped = block.strip()
        if not stripped:
            continue
        first_line = stripped.splitlines()[0]
        if not first_line.startswith("## [THESIS] "):
            continue
        title = first_line[len("## [THESIS] ") :].strip()
        if not has_existing_thesis(existing_content, title):
            kept.append(stripped)

    if not kept:
        return ""

    return "\n\n".join(kept).rstrip() + "\n"


def append_mode(file_path: str, idea: str, model: str) -> int:
    existing = read_file(file_path)
    prompt = build_append_prompt(idea, existing)

    try:
        structured = call_llm_structured(prompt, model)
        new_text = format_brainstorm_block(structured)
    except Exception as e:
        print(f"[brainstorm] append failed: {e}", file=sys.stderr)
        return 1

    if not new_text.strip():
        print(
            "[brainstorm] append failed: empty formatted output",
            file=sys.stderr,
        )
        return 1

    payload = ensure_separator(existing, new_text)
    append_text(file_path, payload)
    print(f"[brainstorm] appended idea to {file_path}")
    return 0


def synthesize_mode(file_path: str, model: str) -> int:
    existing = read_file(file_path)

    if not existing.strip():
        print(
            "[brainstorm] synthesis skipped: brainstorm file is empty",
            file=sys.stderr,
        )
        return 1

    existing_tags = extract_existing_tags(existing)
    idea_headers = extract_idea_headers(existing)
    prompt = build_synthesis_prompt(existing, existing_tags, idea_headers)

    try:
        generated = call_llm(prompt, model)
    except Exception as e:
        print(f"[brainstorm] synthesis failed: {e}", file=sys.stderr)
        return 1

    if not generated.strip():
        print(
            "[brainstorm] synthesis failed: empty model output", file=sys.stderr
        )
        return 1

    deduped = dedupe_theses(existing, generated)
    if not deduped.strip():
        print("[brainstorm] synthesis produced no new thesis blocks")
        return 0

    payload = ensure_separator(existing, deduped)
    append_text(file_path, payload)
    print(f"[brainstorm] appended synthesis to {file_path}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Append ideas or synthesize theses into a brainstorm file."
    )
    parser.add_argument("--file", required=True, help="Path to brainstorm file")
    parser.add_argument("--idea", help="Idea text to append")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="Model name")
    parser.add_argument(
        "--synthesize",
        action="store_true",
        help="Run synthesis instead of append mode",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.synthesize:
        return synthesize_mode(args.file, args.model)

    if not args.idea or not args.idea.strip():
        print("[brainstorm] append mode requires --idea", file=sys.stderr)
        return 1

    return append_mode(args.file, args.idea.strip(), args.model)


if __name__ == "__main__":
    raise SystemExit(main())
