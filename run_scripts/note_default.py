#!/usr/bin/env python3
import sys
import datetime
import os

import re
import argparse


class FileParser:
    def __init__(self, path):
        self.path = path
        self.content = open(path, "r").read()

    def parse(self):
        # Matches ## Today, ## This Week, ## This Month, ## Unplanned groups and # Upcoming Events
        todo_pattern = "[ \t]*- \[\s*\.?\s*(o?O?)\s*\] .+"
        # Finding all matches
        self.todos = [x for x in self.content.split("\n") if re.match(todo_pattern, x)]

        event_pattern = "(.*)( @ )(\d{4}-\d{2}-\d{2})(.*)"
        self.events = [
            x for x in self.content.split("\n") if re.match(event_pattern, x)
        ]

    def print(self):
        print(
            """

| Time | AM                 | PM                |
|------|--------------------|-------------------|
| 1    | Sleep              | Lunch             |
| 2    | Sleep              |                   |
| 3    | Sleep              |                   |
| 4    | Sleep              |                   |
| 5    | Sleep              |                   |
| 6    | Sleep              |                   |
| 7    | Wakeup + Breakfast |                   |
| 8    |                    |                   |
| 9    |                    |                   |
| 10   |                    |                   |
| 11   |                    |                   |
| 12   |                    |                   |

"""
        )
        print("# Upcoming Events\n")
        for event in self.events:
            print(event)
        print("")
        print("# To Do\n")
        for todo in self.todos:
            print(todo)
        print("")


template = """---
title: {name}
author: Alfie Chadwick
date: "Created: {date} | Knit: `r format(Sys.time(), '%d %B, %Y')`"
---

"""

parser = argparse.ArgumentParser(description="Check if file exists.")
parser.add_argument("file", metavar="F", type=str, help="file to check")

args = parser.parse_args()

# get the filename along with extension
filename_with_ext = os.path.basename(args.file)
# strip the extension to get only the name
name, ext = os.path.splitext(filename_with_ext)

date = datetime.date.today().strftime("%d %B, %Y")

print(template.format(name=name, date=date))


if re.match(r"\/wiki\/\d{4}-\d{2}-\d{2}.qmd", args.file):
    file_date = datetime.datetime.strptime(name, "%Y-%m-%d") + datetime.timedelta(
        days=-1
    )

    while True:
        running_name = f'/wiki/{file_date.strftime("%Y-%m-%d")}.qmd'
        if os.path.isfile(running_name):
            break
        else:
            file_date += datetime.timedelta(days=-1)

    parser = FileParser(running_name)
    parser.parse()
    parser.print()
