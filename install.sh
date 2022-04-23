#!/bin/bash
GIT_EMAIL="mk_dev@mail.ru"
GIT_USERNAME="alpineQ"

BITWARDEN_EMAIL=""
BITWARDEN_PASSWORD=""
BITWARDEN_SERVER_URL=""

check_installed() {
    if which "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

if check_installed apt; then
    SEARCH_PKG="apt-cache search"
    INSTALL_CMD="sudo apt-get install -y"
    INSTALL_UPGRADE="sudo apt-get update && sudo apt-get upgrade -y"
elif check_installed pacman; then
    SEARCH_PKG="pacman -Ss"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    INSTALL_UPGRADE="sudo pacman -Su --noconfirm"
else
    echo "Not found supported package manager (apt/pacman)"
    exit 1
fi

install_packages() {
    for package in "$@"
    do
        if check_installed "$package"; then
            echo "INSTALL LOG: $package already installed"
        elif [ -z "$($SEARCH_PKG ^$package\$)" ]; then
            echo "INSTALL LOG: $package was not found in package manager"
        else
            $INSTALL_CMD "$package"
        fi
    done
}

install_base_tools() {
    echo "INSTALL LOG: INSTALLING BASE TOOLS"
    install_packages build-essential cmake curl jq git net-tools xclip python3 python3-pip
}

install_zsh() {
    echo "INSTALL LOG: INSTALLING ZSH"
    install_packages zsh
    sh -c "$(wget -qO - https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -s --batch || {
      echo "INSTALL LOG: Could not install Oh My Zsh" >/dev/stderr
      exit 1
    }
    cat shell_functions.sh >> ~/.zshrc
}

install_npm() {
    echo "INSTALL LOG: INSTALLING NPM"
    install_packages npm
    if check_installed node; then
        return
    fi
    sudo npm install -g n
    sudo n stable
    sudo npm install -g npm@latest
}

install_golang() {
    echo "INSTALL LOG: INSTALLING GOLANG"
    install_packages golang
}

install_python() {
    install_packages python3
    PYTHON_BINARY_PATH=$(which python3)
    if check_installed zsh; then
        echo "alias python=\"\"" >> ~/.zshrc
        echo "alias pip=\"$PYTHON_BINARY_PATH -m pip\"" >> ~/.zshrc
        echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.zprofile
    fi
    echo "alias python=\"$PYTHON_BINARY_PATH\"" >> ~/.bashrc
    echo "alias pip=\"$PYTHON_BINARY_PATH -m pip\"" >> ~/.bashrc
    echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.profile
    
    python3 -m pip install pylint --user
}

install_python_from_source() {
    local N_PROC
    echo "INSTALL LOG: INSTALLING LATEST PYTHON FROM SOURCE"
    install_packages build-essential gdb lcov libbz2-dev libffi-dev \
      libgdbm-dev liblzma-dev libncurses5-dev libreadline6-dev \
      libsqlite3-dev libssl-dev lzma lzma-dev tk-dev uuid-dev zlib1g-dev
    sudo pip install --upgrade pip
    
    wget -q "https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz"
    tar zxf Python-3.10.0.tgz && rm -rf Python-3.10.0.tgz
    cd Python-3.10.0 || exit
    
    if check_installed nproc; then
        N_PROC=$(nproc)
    else
        N_PROC=4
    fi
    
    ./configure --enable-optimizations
    make -j $N_PROC
    sudo make -j $N_PROC altinstall
    cd .. && sudo rm -rf Python-3.10.0
    
    sudo ln -s /usr/share/pyshared/lsb_release.py /usr/local/lib/python3.10/site-packages/lsb_release.py
    sudo ln -sf "$(which python3)" "$PYTHON_BINARY_PATH"
    python3 -m pip install pylint --user
}

install_vim() {
    echo "INSTALL LOG: INSTALLING VIM"
    install_packages vim
    
    if [[ -d ~/.vim/bundle/Vundle.vim ]]; then
        echo "Vim plugins already installed!"
        return
    fi
    echo "INSTALL LOG: INSTALLING VIM PLUGINS"
    cp vim.config ~/.vimrc
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim -q
    sudo npm install -g livedown
    vim --clean '+source ~/.vimrc' +PluginInstall +qall
    python3 ~/.vim/bundle/YouCompleteMe/install.py
}

install_tmux() {
    echo "INSTALL LOG: INSTALLING TMUX"
    install_packages tmux
    
    git clone https://github.com/gpakosz/.tmux.git ~/.tmux -q
    ln -s -f ~/.tmux/.tmux.conf ~
    cp ~/.tmux/.tmux.conf.local ~
    if check_installed zsh; then
        sed -i "12iset -g default-shell $(which zsh)" ~/.tmux.conf
    fi
}

install_tldr() {
    if check_installed tldr; then
        echo "INSTALL LOG: tldr already installed"
        return
    fi
    echo "INSTALL LOG: INSTALLING TLDR"
    sudo npm install -g tldr
    tldr --update
}

install_docker() {
    if check_installed docker; then
        echo "INSTALL LOG: docker already installed"
        return
    fi
    echo "INSTALL LOG: INSTALLING DOCKER"

    sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker "$USER"
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    newgrp docker
}

install_docker_compose() {
    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
    chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
}

install_ngrok() {
    if check_installed ngrok; then
        echo "INSTALL LOG: ngrok already installed"
        return
    fi
    echo "INSTALL LOG: INSTALLING NGROK"
    wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
    unzip ngrok-stable-linux-amd64.zip
    rm -rf ngrok-stable-linux-amd64.zip
    sudo mv ngrok /usr/bin
}

install_ssh_keys() {
    if [ -f "$HOME/.ssh/id_rsa" ]; then
        echo "INSTALL LOG: ssh keys loaded"
        return
    fi
    local BITWARDEN_LOGIN_OUTPUT
    local SSH_KEY_INFO
    echo "INSTALL LOG: LOADING SSH KEYS"
    if [ -z "$BITWARDEN_PASSWORD" ]; then
    	read -rp "Load ssh keys from Bitwarden? [Y/n]: " ans
    else
        ans="Y"
    fi
    if [ "$ans" != "n" ]; then
	install_npm
	install_packages jq
	mkdir ~/.ssh
        sudo npm install -g @bitwarden/cli
        if [ -z "$BITWARDEN_SERVER_URL" ]; then
        	read -rp "Bitwarden server: " BITWARDEN_SERVER_URL
        fi
        bw config server "$BITWARDEN_SERVER_URL"
        BITWARDEN_LOGIN_OUTPUT=$(bw login "$BITWARDEN_EMAIL" "$BITWARDEN_PASSWORD")
        echo ${BITWARDEN_LOGIN_OUTPUT}
        echo ${BITWARDEN_LOGIN_OUTPUT:130:88}
        bw sync --session ${BITWARDEN_LOGIN_OUTPUT:130:88}
        SSH_KEY_INFO=$(bw get item "SSH key" --session ${BITWARDEN_LOGIN_OUTPUT:130:88})
        echo "$SSH_KEY_INFO" | jq ".fields[] | select((.name == \"id_rsa.pub\")).value" -r > "$HOME/.ssh/id_rsa.pub"
        chmod 644 "$HOME/.ssh/id_rsa.pub"
        echo "$SSH_KEY_INFO" | jq ".notes" -r > "$HOME/.ssh/id_rsa"
        chmod 600 "$HOME/.ssh/id_rsa"
        sudo npm uninstall -g @bitwarden/cli
        rm -rf ~/.config/Bitwarden\ CLI/
    else
        ssh-keygen -b 2048 -t rsa -f "$HOME/.ssh/id_rsa" -q -N ""
    fi
}

git_login() {
    echo "INSTALL LOG: SETTING UP GIT USERNAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global user.name "$GIT_USERNAME"
}

install_desktop_tools() {
    echo "INSTALL LOG: INSTALLING DESKTOP TOOLS"
    install_packages ktorrent gnome-tweak-tool gparted telegram-desktop vlc
}

repo_origin() {
    git remote remove origin
    git remote add origin git@github.com:"$GIT_USERNAME"/linux_configs.git
}

install_server() {
    $INSTALL_UPGRADE
    
    install_base_tools
    install_npm
    git_login
    install_ssh_keys
    
    install_zsh
    install_python
    install_vim
    install_tmux
    
    install_docker
    install_docker_compose
    install_golang
    install_tldr
    install_ngrok
}

install_desktop() {
    server
    install_desktop_tools
}

if [[ 0 -eq $# ]]; then
	install_server
elif [[ -n "$(declare -f install_"$1")" ]]; then
    "install_$1"
elif [[ -n $1 &&  -n "$(declare -f "$1")" ]]; then
    "$1"
else
    echo "INSTALL LOG: $1 is not a known install script"
    exit 1
fi
