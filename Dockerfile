FROM ubuntu as vim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Melbourne
# Enviroment Installs 
RUN apt-get update && apt-get install -y \
   curl git python3 python3-pip apt-transport-https \
   ca-certificates software-properties-common  libpq-dev \
   build-essential autoconf automake libtool jq

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
run git config --global user.name "Fonzzy1"
run git config --global user.email "alfiechadwick@hotmail.com"

# Set the base work dir
WORKDIR /src

# Set the mount point as the safe dir
RUN git config --global --add safe.directory /src


# Enviroment Installs 
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:jonathonf/vim
RUN apt-get update

# Install the rest of the dependencies
RUN apt-get install -y \
    tig \
    fzf \
    pkg-config \
    texlive \
    r-base \
    pandoc \
    texlive-latex-extra \
    libcurl4-openssl-dev \
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
    vim-gtk3 

#Install Ctags
RUN curl -L https://github.com/thombashi/universal-ctags-installer/raw/master/universal_ctags_installer.sh | bash

# Install node
RUN set -uex 
RUN mkdir -p /etc/apt/keyrings 
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg 
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" |  tee /etc/apt/sources.list.d/nodesource.list 
RUN apt-get update && apt-get install nodejs -y;


# Install the python packages
RUN pip3 install torch  --index-url https://download.pytorch.org/whl/cpu
RUN pip install black pipreqs pgcli awscli socli sentence_transformers InquirerPy

# Install npm packages
RUN npm install --save-dev --global prettier

# Download and Install Vim-Plug
RUN curl -fLo /root/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

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
RUN R -e  "install.packages('languageserver',  Ncpus = 6)"

# Bring in the vim config
COPY vim /root/.vim
RUN vim +PlugInstall +qall
# Install COC plugins
RUN mkdir -p /root/.config/coc/extensions && \
    echo '{"dependencies":{}}' > /root/.config/coc/extensions/package.json && \
    grep 'let g:coc_global_extensions' /root/.vim/config/coc.vim | \
    sed "s/.*\[//; s/\].*//; s/'//g; s/, /\n/g" | \
    while read -r extension; do \
        echo "Installing coc extension: $extension" && \
        cd /root/.config/coc/extensions && \
        npm install "$extension" --install-strategy=shallow --save; \
    done


#Copy in the dotfiles
COPY dotfiles /root

#Copy in the scripts
COPY run_scripts /scripts

# Overwrite defaule xsg-open call
COPY run_scripts/open.py /usr/bin/xdg-open   

# Download LM 
RUN  /scripts/download_model.py

CMD vim
