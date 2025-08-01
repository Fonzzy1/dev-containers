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
    rsync \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    git-flow \
    libtiff5-dev \
    default-jre \
    libjpeg-dev \
    r-cran-tidyverse \
    xclip \
    poppler-utils \
    fontconfig \
    cmake \
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
    luarocks \
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

RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit -D -t /usr/local/bin/ 

# Install node
RUN set -uex && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
    gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | \
    tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install nodejs -y;

# Install the python packages
RUN pip install mdformat-black mdformat-config pipreqs pgcli awscli ipython ipykernel neovim-remote pynvim openai ddgr googlesearch-python requests feedparser aiohttp bibli_ls pillow mutagen codespell && \
    pip install --no-cache-dir --force-reinstall git+https://github.com/sciunto-org/python-bibtexparser@main

# Install npm packages
RUN npm install --save-dev --global prettier tree-sitter-cli

# Install ACT extention
RUN mkdir -p /root/.local/share/gh/extensions/gh-act && \
    curl -L -o /root/.local/share/gh/extensions/gh-act/gh-act \
    "https://github.com/nektos/gh-act/releases/download/v0.2.57/linux-amd64" && \
    chmod +x /root/.local/share/gh/extensions/gh-act/gh-act

# Install R packages, tidyvverse is installed with apt
RUN R -e "install.packages(c('rmarkdown', 'reticulate', 'readxl', 'knitr'), Ncpus = 6)"
## Install go 
# Download and install Go
COPY --from=golang:1.24-bullseye /usr/local/go/ /usr/local/go/

# Set up Go environment
ENV PATH="/usr/local/go/bin:${PATH}"

#Install rust
RUN curl  --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Quarto
RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb && \
    gdebi --non-interactive quarto-linux-amd64.deb && \
    quarto install tinytex


# Chrome 
RUN curl -L http://bit.ly/google-chrome-stable -o chrome.deb && \
    apt-get -y install ./chrome.deb && \
    rm chrome.deb

RUN fc-cache -fv

#Copy in the dotfiles
COPY dotfiles /root
COPY dotfiles/.bashrc /root/.bash_profile

# Install nvim
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -xzf nvim-linux-x86_64.tar.gz && \
    mv nvim-linux-x86_64 /usr/local/ && \
    ln -s /usr/local/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# Bring in the vim config
COPY vim/vimscript/plugins.vim /root/.config/nvim/vimscript/plugins.vim
COPY vim/lua/tree_config.lua /root/.config/nvim/lua/tree_config.lua
# Download and Install Vim-Plug
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
RUN nvim -u /root/.config/nvim/vimscript/plugins.vim +PlugInstall +qall
RUN nvim -u /root/.config/nvim/vimscript/plugins.vim --headless "+lua require('mason').setup()" "+MasonInstall prisma-language-server vim-language-server yaml-language-server yamlfmt prisma-language-server vim-language-server docker-compose-language-service dockerfile-language-server json-lsp typescript-language-server  yaml-language-server nginx-language-server pyright air ltex-ls lua-language-server mdformat black fixjson prettier shellharden" +qall
RUN timeout 60s nvim -u /root/.config/nvim/vimscript/plugins.vim '+lua require("tree_config")' "+TSUpdateSync" || exit 0

# Copy in the rest of the conig
COPY vim/vimscript /root/.config/nvim/vimscript
COPY vim/lua /root/.config/nvim/lua
COPY vim/init.vim /root/.config/nvim/init.vim
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
