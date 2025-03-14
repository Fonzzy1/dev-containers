# Start from the official Ubuntu base image
FROM ubuntu:22.04 AS vim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Melbourne
ENV TERM="tmux-256color"
WORKDIR /src

RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
# Combine apt-get update and install operations to take advantage of Docker layer caching.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    tig \
    fzf \
    pkg-config \
    texlive \
    r-base \
    pandoc \
    texlive-latex-extra \
    pandoc-citeproc \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    r-cran-tidyverse \
    xclip \
    poppler-utils \
    fontconfig \
    curl \
    git \
    python3 \
    python3-pip \
    apt-transport-https \
    python3.10-venv \
    ca-certificates \
    libpq-dev \
    build-essential \
    autoconf \
    automake \
    libtool \
    jq \
    gdebi-core \
    wget \
    ripgrep && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  && \
    fc-cache -fv


#Install Docker 
RUN curl -fsSL https://get.docker.com -o install-docker.sh \
    && sh install-docker.sh 

# Install GH CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

# git
RUN git config --global user.name "Fonzzy1" && \
    git config --global user.email "alfiechadwick@hotmail.com" && \
    git config --global core.editor "nvr --remote-wait -cc split +\"set bufhidden=delete\"" && \
    git config --global --add safe.directory /src

# Install node
RUN set -uex && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
    gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | \
    tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install nodejs -y;

# Install the python packages
RUN pip install pipreqs pgcli awscli ipython ipykernel neovim-remote pynvim openai ddgr && \
    pip install --no-cache-dir --force-reinstall git+https://github.com/sciunto-org/python-bibtexparser@main

# Install npm packages
RUN npm install --save-dev --global prettier tree-sitter-cli

# Install ACT extention
RUN mkdir -p /root/.local/share/gh/extensions/gh-act && \
    curl -L -o /root/.local/share/gh/extensions/gh-act/gh-act \
    "https://github.com/nektos/gh-act/releases/download/v0.2.57/linux-amd64" && \
    chmod +x /root/.local/share/gh/extensions/gh-act/gh-act

# Install R packages, tidyvverse is installed with apt
RUN R -e "install.packages(c('rmarkdown', 'reticulate', 'blogdown', 'readxl', 'knitr', 'tinytex'), Ncpus = 6)" && R -e 'blogdown::install_hugo()'

# Install all the Language Servers
#Vimscript
#Docker File
# Json
# Markdown
# Nginx
# Python
# R
# SQL
# Typescript
# YAML
# JS 
# English
RUN npm install -g vim-language-server dockerfile-language-server-nodejs \
    vscode-json-languageserver sql-language-server typescript-language-server \
    typescript yaml-language-server quick-lint-js \
    && \
    curl -L -o /bin/marksman "https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64"  &&  chmod +x /bin/marksman \
    && \
    pip install -U nginx-language-server pyright \
    && \
    R -e "install.packages('languageserver', Ncpus = 6)" \
    && \
    curl -L https://github.com/valentjn/ltex-ls/releases/download/16.0.0/ltex-ls-16.0.0-linux-x64.tar.gz |  tar xz --strip-components=1 && mv ltex-ls-16.0.0 /usr/bin/ltex-ls

# Quarto
RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    gdebi --non-interactive quarto-linux-amd64.deb && \
    quarto install tinytex

RUN fc-cache -fv

# Is-fast
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/Magic-JD/is-fast/releases/latest/download/is-fast-installer.sh | sh

#Copy in the dotfiles
COPY dotfiles /root
COPY dotfiles/.bashrc /root/.bash_profile

# Install nvim
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -xzf nvim-linux-x86_64.tar.gz && \
    mv nvim-linux-x86_64 /usr/local/ && \
    ln -s /usr/local/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# Bring in the vim config
COPY vim /root/.config/nvim/
# Download and Install Vim-Plug
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
RUN nvim -u /root/.config/nvim/vimscript/plugins.vim +PlugInstall +qall

#Copy in the scripts
COPY run_scripts /scripts
# Overwrite defaule xsg-open call
COPY run_scripts/open.py /usr/bin/xdg-open   

# Set the editor
ENV EDITOR='nvr --remote-wait -cc split +"set bufhidden=delete"'
ENV VISUAL='nvr --remote-wait -cc split +"set bufhidden=delete"'
ENV GH_EDITOR='nvr --remote-wait -cc split +"set bufhidden=delete"'
ENV GIT_EDITOR='nvr --remote-wait -cc split +"set bufhidden=delete"'


CMD nvim --listen /tmp/nvimsocket
