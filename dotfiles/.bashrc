#!/bin/bash

# don't put duplicate lines or lines starting with space in the history.
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
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ollama='docker exec ollama ollama'
alias 'ollama serve'='docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama'

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

alias vim='nvim'
source "$HOME"/.cargo/env 

# Function to parse git branch
function parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1="\[\e[0;32m\]\A \[\e[1;34m\]\u\[\e[0;37m\]@\[\e[0;34m\]\h \[\e[0;35m\]\w \[\e[0m\]|> "

function gitdist() {
    for branch in "$(git branch -a --format='%(refname:short)')"; do
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
