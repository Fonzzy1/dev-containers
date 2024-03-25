#!/usr/bin/env python3
import subprocess
import os
from urllib.parse import urlparse
import sys


def is_url(path):
    try:
        result = urlparse(path)
        return all([result.scheme, result.netloc])
    except ValueError:
        return False


def path_to_command(path):
    if is_url(path):
        return f'xdg-open "{path}"'

    sys_dir = os.environ["SYS_DIR"]
    cont_dir = os.environ["CONT_DIR"]

    if path == None:
        return f'xdg-open "{sys_dir}"'

    if not path.startswith(cont_dir):
        os.system(
            f"echo 'Path {path} is not within the container directory {cont_dir}. Skipping operation.' >> /root/.xgd_log.txt"
        )  # Adds command to log.txt
        return None
    else:

        path = path.replace(cont_dir, sys_dir)
        return f'xdg-open "{path}"'


if __name__ == "__main__":
    try:
        path = sys.argv[1]
    except:
        path = None
    command = path_to_command(sys.argv[1])
    os.system(f"echo '{command}' >> /root/.xgd_log.txt")  # Adds command to log.txt
    os.system(f"echo '{command}' > /pipe")
