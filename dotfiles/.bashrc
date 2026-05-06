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
alias ollama='docker exec -it ollama ollama'

mpall() {

  for dev in /dev/sd*[0-9]; do
    [ -e "$dev" ] || continue
    pmount --exec --fmask 000 "$dev" >/dev/null 2>&1
  done

if [ "$1" = "--setup" ]; then
    mp=$(findmnt -no TARGET -S LABEL=ALFIE 2>/dev/null)
    [ "$mp" != "" ] && "$mp/dev-containers/setup" "$mp"
    return
fi

}

function ollamaserve() {
  docker rm -f ollama 2>/dev/null
  sudo rmmod nvidia_uvm && sudo modprobe nvidia_uvm
  docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
}

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


# Function to parse git branch
function parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1="\[\e[0;32m\]\A \[\e[1;34m\]\u\[\e[0;37m\]@\[\e[0;34m\]\h \[\e[0;35m\]\w \[\e[0m\]|> "

#PATH
export PATH="$HOME/.local/bin:$PATH"


docker_image_cmds() {
  command -v docker >/dev/null 2>&1 || return 0

  while read -r repo tag; do
    [ "$tag" = "latest" ] || continue

    case "$repo" in
      local/*)
        raw_name="${repo#local/}"
        func_name="$(printf '%s' "$raw_name" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_' '_')"
        dockerfile="$HOME/.local/share/dev-containers/Dockerfiles/Dockerfile.${raw_name}"
        default_args=""

        if [ -f "$dockerfile" ]; then
          first_line="$(head -n 1 "$dockerfile")"
          case "$first_line" in
            '# '*)
              default_args="${first_line#\# }"
              ;;
            '#'*)
              default_args="${first_line#\#}"
              ;;
          esac
        fi

        eval "
${func_name}() {
  local env_args=()

  if [ -f \"\$HOME/.config/env\" ]; then
    env_args=(--env-file \"\$HOME/.config/env\")
  fi

  docker run -it --rm \
    --user \"\$(id -u):\$(id -g)\" \
    \"\${env_args[@]}\" \
    -v \"\$PWD:/work\" \
    -w /work \
    ${default_args} \
    ${repo}:${tag} \"\$@\"
}
"
        ;;
    esac
  done < <(docker images --format '{{.Repository}} {{.Tag}}')
}

docker_image_cmds

opl() {
  local copy_cmd open_cmd

  copy_cmd="xclip -selection clipboard"
  open_cmd="xdg-open"

  op item list --format json | jq -r '
    .[] |
    [
      .id,
      (.title // ""),
      ((.tags // []) | join(", ")),
      (([.urls[]?.href] // []) | join(", "))
    ] | @tsv
  ' | fzf \
    --delimiter=$'\t' \
    --with-nth=2,3,4 \
    --prompt="1Password> " \
    --height=80% \
    --layout=reverse \
    --header $'Enter: open | Ctrl-Y: password | Ctrl-U: user | Ctrl-O: open URL | Ctrl-R: yank refs | Ctrl-I: yank id' \
    --bind "enter:execute-silent(sh -c 'url=\$(op item get {1} --format json | jq -r '\''.urls[0].href // empty'\''); test -n \"\$url\" && nohup ${open_cmd} \"\$url\" >/dev/null 2>&1 < /dev/null &')" \
    --bind "ctrl-y:execute-silent(op item get {1} --fields label=password --reveal 2>/dev/null | ${copy_cmd})" \
    --bind "ctrl-u:execute-silent(op item get {1} --fields label=username 2>/dev/null | ${copy_cmd})" \
    --bind "ctrl-o:execute-silent(sh -c 'url=\$(op item get {1} --format json | jq -r '\''.urls[0].href // empty'\''); test -n \"\$url\" && printf \"%s\" \"\$url\" | ${copy_cmd}')" \
    --bind "ctrl-r:execute-silent(op item get {1} --format json | jq -r '
      .vault.id as \$vault |
      .id as \$item |
      .fields[]? |
      \"op://\(\$vault)/\(\$item)/\(.id)\"
      ' | ${copy_cmd})" \
          --bind "ctrl-i:execute-silent(printf '%s' {1} | ${copy_cmd})"
      }
