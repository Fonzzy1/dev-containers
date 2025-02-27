FROM ubuntu:22.04 AS vim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Melbourne
ENV TERM="tmux-256color"
WORKDIR /src

RUN apt-get update && apt-get install -y software-properties-common 
# Enviroment Installs 
RUN apt-get update && apt-get install -y tig \
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
    python3.10-venv\
    ca-certificates \
    software-properties-common \
    libpq-dev \
    build-essential \
    autoconf \
    automake \
    libtool \
    jq \ 
    gdebi-core \
    ripgrep

#Install Docker 
RUN curl -fsSL https://get.docker.com -o install-docker.sh 
RUN sh install-docker.sh 

# Install GH CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

# git
RUN git config --global user.name "Fonzzy1"
RUN git config --global user.email "alfiechadwick@hotmail.com"
RUN git config --global core.editor "nvr --remote-wait -cc split +\"set bufhidden=delete\""
RUN git config --global --add safe.directory /src

# Install node
RUN set -uex 
RUN mkdir -p /etc/apt/keyrings 
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg 
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" |  tee /etc/apt/sources.list.d/nodesource.list 
RUN apt-get update && apt-get install nodejs -y;

# Install the python packages
RUN pip install pipreqs pgcli awscli ipython ipykernel neovim-remote pynvim scikit-learn openai
RUN pip install --no-cache-dir --force-reinstall git+https://github.com/sciunto-org/python-bibtexparser@main

# Install the fonts
RUN apt remove ttf-mscorefonts-installer --purge -y
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
RUN apt-get update \
  && apt-get -y install --no-install-recommends \
  ttf-mscorefonts-installer
RUN fc-cache -fv

# Install npm packages
RUN npm install --save-dev --global prettier tree-sitter-cli


# Install ACT extention
RUN mkdir -p /root/.local/share/gh/extensions/gh-act
RUN curl -L -o /root/.local/share/gh/extensions/gh-act/gh-act \
    "https://github.com/nektos/gh-act/releases/download/v0.2.57/linux-amd64"
RUN chmod +x /root/.local/share/gh/extensions/gh-act/gh-act

# Install R packages, tidyvverse is installed with apt
RUN R -e  "install.packages('rmarkdown',  Ncpus = 6)"
RUN R -e  "install.packages('reticulate',  Ncpus = 6)"
RUN R -e  "install.packages('blogdown',  Ncpus = 6)"
RUN R -e  "blogdown::install_hugo()"
RUN R -e  "install.packages('readxl',  Ncpus = 6)"
RUN R -e  "install.packages('knitr',  Ncpus = 6)"
RUN R -e  "install.packages('tinytex',  Ncpus = 6)"

# Install all the Language Servers
#Vimscript
RUN npm install -g vim-language-server
#Docker File
RUN npm install -g dockerfile-language-server-nodejs
# Json
RUN npm install -g vscode-json-languageserver
# Markdown
RUN curl -L -o /bin/marksman "https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64" && chmod +x /bin/marksman
# Nginx
RUN pip install -U nginx-language-server
# Python
RUN pip install pyright
# R
RUN R -e  "install.packages('languageserver',  Ncpus = 6)"
# SQL
RUN npm install -g sql-language-server
# Typescript
RUN npm install -g typescript-language-server typescript
# YAML
RUN npm i -g yaml-language-server
# JS 
RUN npm i -g quick-lint-js
# English
RUN curl -L https://github.com/valentjn/ltex-ls/releases/download/16.0.0/ltex-ls-16.0.0-linux-x64.tar.gz | tar xz --strip-components=1 
RUN mv ltex-ls-16.0.0 /usr/bin/ltex-ls

# Quarto
RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb
RUN gdebi --non-interactive quarto-linux-amd64.deb
RUN quarto install tinytex

#Copy in the dotfiles
COPY dotfiles /root
COPY dotfiles/.bashrc /root/.bash_profile


# Install nvim
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
RUN tar -xzf nvim-linux-x86_64.tar.gz
RUN mv nvim-linux-x86_64 /usr/local/
RUN ln -s /usr/local/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

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


