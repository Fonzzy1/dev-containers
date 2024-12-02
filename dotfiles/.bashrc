#!/bin/bash

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export EDITOR='nvr --remote-wait -cc split +"set bufhidden=delete"'
export VISUAL='nvr --remote-wait -cc split +"set bufhidden=delete"'
export GH_EDITOR='nvr --remote-wait -cc split +"set bufhidden=delete"'


# Function to render R Markdown file
function knit() {
    R -e "rmarkdown::render('$1', output_dir = 'knits')"
}

export -f knit

# Function to parse git branch
function parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\u@\h \[\e[32m\]\w \[\e[0;91m\]\$(parse_git_branch) \[\e[0;95m\]\$ENV_STAGE\[\e[00m\]\$ "

function gitdist() {
    for branch in $(git branch -a --format='%(refname:short)'); do
        behind=$(git rev-list --count "${branch}..origin/HEAD")
        ahead=$(git rev-list --count "origin/HEAD..${branch}")

        echo -n "${branch}: "
        
        # If ahead, print in green
        if [ "$ahead" -gt 0 ]; then
            echo -n "$(tput setaf 2)ahead by ${ahead} commits$(tput sgr0) "
        fi

        # If behind, print in red
        if [ "$behind" -gt 0 ]; then
            echo -n "$(tput setaf 1)behind by ${behind} commits$(tput sgr0)"
        fi

        echo
    done
}

