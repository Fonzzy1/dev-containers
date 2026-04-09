#!/usr/bin/env python3
import os
import sys
import subprocess

from urllib.parse import urlparse
import argparse


def is_url(path):
    try:
        result = urlparse(path)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False


def is_text_file(path):
    """Check if a file is text (readable) vs binary."""
    if not os.path.isfile(path):
        return False

    # Explicit text extensions
    text_extensions = {
        # Code
        ".py",
        ".js",
        ".ts",
        ".jsx",
        ".tsx",
        ".json",
        ".yaml",
        ".yml",
        ".toml",
        ".ini",
        ".sh",
        ".bash",
        ".zsh",
        ".fish",
        ".c",
        ".h",
        ".cpp",
        ".hpp",
        ".rs",
        ".go",
        ".java",
        ".rb",
        ".php",
        ".lua",
        ".vim",
        ".r",
        ".scala",
        # Config
        ".vimrc",
        ".gitignore",
        ".env",
        ".conf",
        ".cfg",
        ".dockerignore",
        # Web
        ".css",
        ".scss",
        ".sass",
        ".less",
        ".xml",
        ".svg",
        # Data
        ".csv",
        ".tsv",
        ".txt",
        # Docs
        ".md",
        ".markdown",
        ".qmd",
        # Docs/Other
        ".sql",
        ".log",
        ".git",
    }

    base_name = os.path.basename(path)
    ext = "." + base_name.split(".")[-1].lower() if "." in base_name else ""

    # Check extension
    if ext in text_extensions:
        return True

    # Also check files with no extension (like Makefile, Dockerfile)
    if "." not in base_name:
        return True


def path_to_command(path, reader_flag):
    if is_url(path):
        if reader_flag:
            return f'xdg-open "about:reader?url={path}"'
        else:
            return f'xdg-open "{path}"'

    # If nvim is available and file is text, run nvr inside container
    if is_text_file(path):
        return None, f'nvr -c ":vsplit {path}"'

    sys_dir = os.environ["SYS_DIR"]
    cont_dir = os.environ["CONT_DIR"]

    if path is None:
        return f'xdg-open "{sys_dir}"'
    elif path.startswith(cont_dir):
        path = path.replace(cont_dir, sys_dir)

        return f'xdg-open "{path}"', None
    else:
        os.system(
            f"echo 'Path {path} is not within the container directory {cont_dir}. Skipping operation.' >> /root/.xdg_log.txt"
        )  # Adds command to log.txt
        return None, None


def main():
    parser = argparse.ArgumentParser(description="Process some inputs.")
    parser.add_argument("path", type=str, help="The path to be processed.")
    parser.add_argument(
        "--reader",
        action="store_true",
        help='Appends "about:reader?url=" to the start of the path if it is a url',
    )
    args = parser.parse_args()

    pipe_cmd, local_cmd = path_to_command(args.path, args.reader)

    # Log both commands
    if pipe_cmd:
        os.system(f"echo '{pipe_cmd}' >> /root/.xdg_log.txt")
        os.system(f"echo '{pipe_cmd}' > /pipe")
    if local_cmd:
        os.system(f"echo 'LOCAL: {local_cmd}' >> /root/.xdg_log.txt")
        os.system(local_cmd)


if __name__ == "__main__":
    main()
