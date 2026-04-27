#!/usr/bin/env python3

import os
import subprocess
import argparse
from openai import OpenAI


def get_staged_diff():
    """Get staged git diff."""
    result = subprocess.run(
        ["git", "--no-pager", "diff", "--staged"],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout


def generate_commit_message(model: str, diff: str) -> str:
    """Call OpenAI to generate a commit message."""
    client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

    prompt = (
        "Generate a short commit message from the diff below. "
        "Return only one line.\n\n"
        f"{diff}"
    )

    response = client.responses.create(
        model=model,
        input=[
            {"role": "system", "content": "You are a code assistant."},
            {"role": "user", "content": prompt},
        ],
        temperature=1,
    )

    return response.output_text.strip()


def main():
    parser = argparse.ArgumentParser(
        description="Generate a git commit message from staged diff using OpenAI."
    )
    parser.add_argument("model", help="OpenAI model name (e.g. gpt-4.1-mini)")

    args = parser.parse_args()

    diff = get_staged_diff()

    if not diff.strip():
        print("No staged changes found.")
        return

    message = generate_commit_message(args.model, diff)
    print(message)


if __name__ == "__main__":
    main()
