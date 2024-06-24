#!/usr/bin/env python3
import sys
import calendar
from datetime import datetime, timedelta, time, date
import os
import re
import argparse

class Task:
    def __init__(self, string: str):
        self.string = string
        self.children = []

        pattern = r'\s*- \[.*\]\s(.*)'
        result = re.search(pattern, string)

        self.name = result.group(1).strip()

    def __str__(self):
        return self.name

    def print(self, indent=0):
        print('    '* indent + f'- [ ] {self.name}')
        for child in self.children:
            child.print(indent = indent + 1)

def text2task(indented_text: str):
    lines = indented_text.splitlines()
    root = Task('- [ ] Root') 

    last_parent = {0: root} # last parents encountered by indent level
    for line in indented_text.splitlines():
        node = Task(line.lstrip(' '))
        indent_level = len(line) - len(node.string)
        last_parent[indent_level].children.append(node)
        last_parent[indent_level + 4] = node

    return root.children[0]

class Calendar():
    def __init__(self, events, reccuring) -> None:
        self.events = events
        self.recuring_events = reccuring

    def todays_events(self):

        month_day = int(date.today().strftime('%d'))
        day_week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"][date.today().weekday()]

        reccuring_events = [ x for x in self.recuring_events if x.recur_on in [month_day, day_week]]
        normal_events = [x for x in self.events if x.date == date.today() ]

        combined_events = normal_events + reccuring_events

        # Sorting the combined list by 'start_time'
        sorted_events = sorted(combined_events, key=lambda event: event.start_time)

        for event in sorted_events:
            event.print_agenda()

    def upcoming_events(self):
        for event in [ x for x in self.events if x.date > date.today()]+self.recuring_events:
            event.print_upcoming()


class Event:
    def __init__(self, name, date, start_time=None, length=None):
        self.name = name
        self.date = datetime.strptime(date, '%Y-%m-%d').date()
        self.start_time = start_time
        self.length = length if length else 1

        if self.start_time:
            self.start_time = datetime.strptime(self.start_time,'%H:%M')
            self.end_time = self.start_time + timedelta(hours=self.length)

    def print_agenda(self):
        if self.start_time:
            print(f'{self.name} @ {self.start_time.strftime("%H:%M")}-{self.end_time.strftime("%H:%M")}')
        else:
            print(f'{self.name}')
            
    def print_upcoming(self):
        if self.start_time:
            print(f'{self.date} @ {self.start_time.strftime("%H:%M")} for {self.length} {"hour" if self.length == 1 else "hours"} - {self.name}')
        else:
            print(f'{self.date} - {self.name}')




class RecurringEvent:
    def __init__(self, name, recur_on, start_time=None, length=None):
        self.name = name
        self.recur_on = recur_on
        self.start_time = None
        self.end_time = None
        self.length = length if length else 1
        if start_time:
            self.start_time = self._time_object_from_string(start_time)
            self.end_time = self.start_time + timedelta(hours=length if length else 1)

    def _time_object_from_string(self, time_string):
        return datetime.strptime(time_string, '%H:%M')

    def print_upcoming(self):
        if self.start_time:
            print(f'Every {self.recur_on} @ {self.start_time.strftime("%H:%M")} for {self.length} {"hour" if self.length == 1 else "hours"} - {self.name}')
        else:
            print(f'Every {self.recur_on} - {self.name}')

    def print_agenda(self):
        if self.start_time:
            print(f'{self.name} @ {self.start_time.strftime("%H:%M")}-{self.end_time.strftime("%H:%M")}')
        else:
            print(f'{self.name}')


class FileParser:
    def __init__(self, path):
        self.path = path
        self.content = open(path, "r").read()

    def parse(self):
        lines = self.content.splitlines()
        indices = [i for i, x in enumerate(lines) if x.startswith('##')]

        events = [x for x in lines[indices[0]+1:indices[1]] if x != '']
        to_do =  [ x for x in lines[indices[1]+1:] if x != '']

        ## Parse the to_dos
        to_do = [x for x in to_do if x != '']
        indices = [i for i, x in enumerate(to_do) if x.startswith('-')] + [len(to_do)]
        self.tasks = ['\n'.join(to_do[indices[i]:indices[i+1]]) for i in range(len(indices)-1)]
        self.tasks = [text2task(x) for x in self.tasks]


        # Do the calendar
        events_ls = []
        recurringevents = []

        for event in events:
            regex = r"(\d+-\d+-\d+) @ (\d+:\d+) for ([0-9]*\.?[0-9]+) (hour|hours) - (.*)"
            match = re.match(regex, event)
            if match:
                events_ls.append(Event(match.group(5), match.group(1), match.group(2),float(match.group(3))))
            regex = r"(\d+-\d+-\d+) - (.*)"
            match = re.match(regex, event)
            if match:
                events_ls.append(Event(match.group(2), match.group(1)))
            regex = r"Every (.*) @ (\d+:\d+) for ([0-9]*\.?[0-9]+) (hour|hours) - (.*)"
            match = re.match(regex, event)
            if match:
                recurringevents.append(RecurringEvent(match.group(5), match.group(1), match.group(2),float(match.group(3))))
            regex = r"Every ((?!.*@.*).*) - (.*)"
            match = re.match(regex, event)
            if match:
                recurringevents.append(RecurringEvent(match.group(2), match.group(1)))

        self.cal = Calendar(events_ls,recurringevents)

    def print(self):
        print("## Upcoming Events\n")
        self.cal.todays_events()

        print(' ')

        self.cal.upcoming_events()
        
        print("")
        print("## To Do\n")
        for task in self.tasks:
            task.print()
            print('\n')
        print("")



def main():
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

    print(template.format(name=name, date=date.today().strftime("%d %B, %Y")))


    if re.match(r"\d{4}-\d{2}-\d{2}.qmd", args.file):
        file_date = datetime.strptime(name, "%Y-%m-%d") + datetime.timedelta(
            days=-1
        )

        while True:
            running_name = f'/wiki/{file_date.strftime("%Y-%m-%d")}.qmd'
            if os.path.isfile(running_name):
                break
            else:
                file_date += timedelta(days=-1)

        parser = FileParser(running_name)
        parser.parse()
        parser.print()

if __name__ == '__main__':
    self = FileParser('test2.qmd')
    self.parse()
    self.print()
    input()
    #main()
