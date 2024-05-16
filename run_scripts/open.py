#!/usr/bin/env python3
import os
import sys
from urllib.parse import urlparse
import argparse


def is_url(path):
    try:
        result = urlparse(path)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False


def path_to_command(path, reader_flag):
    if is_url(path):
        if reader_flag:
            return f'xdg-open "about:reader?url={path}"'
        else:
            return f'xdg-open "{path}"'

    sys_dir = os.environ["SYS_DIR"]
    cont_dir = os.environ["CONT_DIR"]

    sys_vault = os.environ["SYS_VAULT"]
    cont_vault = os.environ["VAULT"]

    if path is None:
        return f'xdg-open "{sys_dir}"'
    elif path.startswith(cont_dir):
        path = path.replace(cont_dir, sys_dir)
        return f'xdg-open "{path}"'
    elif path.startswith(cont_vault):
        path = path.replace(cont_vault, sys_vault)
        return f'xdg-open "{path}"'
    else:
        os.system(
            f"echo 'Path {path} is not within the container directory {cont_dir} or vault dir {cont_vault}. Skipping operation.' >> /root/.xgd_log.txt"
        )  # Adds command to log.txt


def main():
    parser = argparse.ArgumentParser(description="Process some inputs.")
    parser.add_argument("path", type=str, help="The path to be processed.")
    parser.add_argument(
        "--reader",
        action="store_true",
        help='Appends "about:reader?url=" to the start of the path if it is a url',
    )
    args = parser.parse_args()

    command = path_to_command(args.path, args.reader)
    os.system(f"echo '{command}' >> /root/.xgd_log.txt")  # Adds command to log.txt
    os.system(f"echo '{command}' > /pipe")


if __name__ == "__main__":
    main()
