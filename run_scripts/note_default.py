#!/usr/bin/env python3
import sys
from datetime import datetime, timedelta, time, date
import os
import re
import argparse




def main():
    template = """---
title: {name}
author: Alfie Chadwick
date: "{date}"
filters:
    - /scripts/callouts.lua
---
"""

    parser = argparse.ArgumentParser()
    parser.add_argument("file", metavar="F", type=str, help="file to check")

    args = parser.parse_args()

    # get the filename along with extension
    filename_with_ext = os.path.basename(args.file)
    # strip the extension to get only the name
    name, ext = os.path.splitext(filename_with_ext)

    print(template.format(name=name, date=date.today().strftime("%Y-%m-%d")))

if __name__ == '__main__':
    main()

