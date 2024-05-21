#!/usr/bin/env python3
import sys
import datetime
import os

template = """---
title: {name}
author: Alfie Chadwick
date: "Created: {date} | Knit: `r format(Sys.time(), '%d %B, %Y')`"
output: pdf_document
description:
---

# {name}
"""

date = datetime.date.today().strftime("%d %B, %Y")
# get the filename along with extension
filename_with_ext = os.path.basename(sys.argv[1])
# strip the extension to get only the name
name, ext = os.path.splitext(filename_with_ext)
print(template.format(name=name, date=date))
