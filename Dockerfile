# Start from the official Ubuntu base image
FROM ubuntu:22.04 AS vim

ARG BUILD_DATE
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Melbourne
ENV TERM="tmux-256color"
WORKDIR /src

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
    ttf-mscorefonts-installer \
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
    ripgrep && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Docker
RUN curl -fsSL https://get.docker.com | sh

# Install GH CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Git configuration
RUN git config --global user.name "Fonzzy1" && \
    git config --global user.email "alfiechadwick@hotmail.com" && \
    git config --global core.editor "nvr --remote-wait -cc split +\"set bufhidden=delete\"" && \
    git config --global --add safe.directory /src

# Install Node.js and npm
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir pipreqs pgcli awscli ipython ipykernel neovim-remote pynvim scikit-learn openai && \
    pip install --no-cache-dir --force-reinstall git+https://github.com/sciunto-org/python-bibtexparser@main

# Install fonts
RUN apt-get purge -y ttf-mscorefonts-installer && \
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections && \
    apt-get update && \
    apt-get -y install --no-install-recommends ttf-mscorefonts-installer && \
    fc-cache -fv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install npm packages
RUN npm install --save-dev --global prettier tree-sitter-cli

# Install ACT extension
RUN mkdir -p /root/.local/share/gh/extensions/gh-act && \
    curl -L -o /root/.local/share/gh/extensions/gh-act/gh-act "https://github.com/nektos/gh-act/releases/download/v0.2.57/linux-amd64" && \
    chmod +x /root/.local/share/gh/extensions/gh-act/gh-act

# Install R packages
RUN R -e "install.packages(c('rmarkdown', 'reticulate', 'blogdown', 'readxl', 'knitr', 'tinytex'), repos='http://cran.rstudio.com/', Ncpus = 6)" && \
    R -e "blogdown::install_hugo()"

# Language Servers installations using npm and pip
RUN npm install -g vim-language-server dockerfile-language-server-nodejs vscode-json-languageserver sql-language-server typescript-language-server typescript yaml-language-server quick-lint-js && \
    pip install -U nginx-language-server pyright && \
    R -e "install.packages('languageserver', repos='http://cran.rstudio.com/', Ncpus = 6)"

# Install Quarto and tinytex
RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    gdebi --non-interactive quarto-linux-amd64.deb && \
    quarto install tinytex

# Copy dotfiles and other configurations
COPY dotfiles /root
COPY dotfiles/.bashrc /root/.bash_profile

# Install Neovim
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -xzf nvim-linux-x86_64.tar.gz && \
    mv nvim-linux-x86_64 /usr/local/ && \
    ln -s /usr/local/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# Set up Neovim configuration
COPY vim /root/.config/nvim/
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' && \
    nvim -u /root/.config/nvim/vimscript/plugins.vim +PlugInstall +qall

# Copy scripts and overwrite the default xdg-open call
COPY run_scripts /scripts
COPY run_scripts/open.py /usr/bin/xdg-open

# Set editor environment variables
ENV EDITOR='nvr --remote-wait -cc split +"set bufhidden=delete"'
ENV VISUAL='nvr --remote-wait -cc split +"set bufhidden=delete"'
ENV GH_EDITOR='nvr --remote-wait -cc split +"set bufhidden=delete"'
ENV GIT_EDITOR='nvr --remote-wait -cc split +"set bufhidden=delete"'

CMD nvim --listen /tmp/nvimsocket
