#!/bin/bash
GIT_EMAIL=""
GIT_USERNAME=""

check_installed() {
    if which $1 &> /dev/null; then
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
    $INSTALL_UPGRADE
    for package in $@
    do
        if check_installed "$package"; then
            echo "INSTALL LOG: $package already installed"
        elif [ -z "`$SEARCH_PKG ^$package\$`" ]; then
            echo "INSTALL LOG: $package was not found in package manager"
        else
            $INSTALL_CMD $package
        fi
    done
}

install_base_tools() {
    echo "INSTALL LOG: INSTALLING BASE TOOLS"
    install_packages build-essential cmake curl jq git net-tools xclip python3 python3-pip
}

install_zsh() {
    if check_installed zsh; then
        return
    fi
    echo "INSTALL LOG: INSTALLING ZSH"
    install_packages zsh
    sh -c "`wget -qO - https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh`" -s --batch || {
      echo "INSTALL LOG: Could not install Oh My Zsh" >/dev/stderr
      exit 1
    }
    echo "
gethash() {
    echo \$1 | md5sum | head -c 32 | xclip -sel clip
    exit
}" >> ~/.zshrc
}

install_npm() {
    if check_installed npm; then
        return
    fi
    echo "INSTALL LOG: INSTALLING NPM"
    install_packages -y npm
    sudo npm install -g n
    sudo n stable
    sudo npm install -g npm@latest
}

install_golang() {
    if check_installed go; then
        return
    fi
    echo "INSTALL LOG: INSTALLING GOLANG"
    wget -q https://golang.org/dl/go1.17.1.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz
    rm -rf go1.17.1.linux-amd64.tar.gz
    if check_installed zsh; then
        echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.zprofile
    fi
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
    
    /usr/local/go/bin/go install -v golang.org/x/tools/gopls@latest
    /usr/local/go/bin/go install -v github.com/ramya-rao-a/go-outline@latest
}

install_python() {
    if check_installed python3.10; then
        return
    fi
    
    echo "INSTALL LOG: INSTALLING LATEST PYTHON"
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    install_packages python3.10
    python3 -m pip install --upgrade pip
    local PYTHON_BINARY_PATH=`which python3.10`
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
    echo "INSTALL LOG: INSTALLING LATEST PYTHON FROM SOURCE"
    install_packages build-essential gdb lcov libbz2-dev libffi-dev \
      libgdbm-dev liblzma-dev libncurses5-dev libreadline6-dev \
      libsqlite3-dev libssl-dev lzma lzma-dev tk-dev uuid-dev zlib1g-dev
    sudo pip install --upgrade pip
    
    wget -q "https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz"
    tar zxf Python-3.10.0.tgz && rm -rf Python-3.10.0.tgz && cd Python-3.10.0
    
    if check_installed nproc; then
        local NPROC=`nproc`
    else
        NPROC=4
    fi
    
    ./configure --enable-optimizations
    make -j $NPROC
    sudo make -j $NPROC altinstall
    cd .. && sudo rm -rf Python-3.10.0
    
    sudo ln -s /usr/share/pyshared/lsb_release.py /usr/local/lib/python3.10/site-packages/lsb_release.py
    sudo ln -sf `which python3` $PYTHON_BINARY_PATH
    python3 -m pip install pylint --user
}

install_vim() {
    echo "INSTALL LOG: INSTALLING VIM"
    if ! check_installed vim; then
        install_packages vim
    fi
    
    if [[ -d ~/.vim/bundle/Vundle.vim ]]; then
        echo "Vim plugins already installed!"
        return
    fi
    echo "INSTALL LOG: INSTALLING VIM PLUGINS"
    cp .vimrc ~
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim -q
    sudo npm install -g livedown
    vim --clean '+source ~/.vimrc' +PluginInstall +qall
    python3 ~/.vim/bundle/YouCompleteMe/install.py
}

install_tmux() {
    if check_installed tmux; then
        return
    fi
    echo "INSTALL LOG: INSTALLING TMUX"
    install_packages tmux
    
    sudo chsh $USER -s `which tmux`
    git clone https://github.com/gpakosz/.tmux.git ~/.tmux -q
    ln -s -f ~/.tmux/.tmux.conf ~
    cp ~/.tmux/.tmux.conf.local ~
    if check_installed zsh; then
        sed -i "12iset -g default-shell `which zsh`" ~/.tmux.conf
    fi
}

install_tldr() {
    if check_installed tldr; then
        return
    fi
    echo "INSTALL LOG: INSTALLING TLDR"
    sudo npm install -g tldr
    tldr --update
}

install_docker() {
    if check_installed docker; then
        return
    fi
    echo "INSTALL LOG: INSTALLING DOCKER"
    wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  `lsb_release -cs`  stable"
    install_packages docker-ce
    
    sudo usermod -aG docker $USER
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
}

install_docker_compose() {
    if check_installed docker-compose; then
        return
    fi
    echo "INSTALL LOG: INSTALLING DOCKER COMPOSE"
    local COMPOSE_VERSION="docker-compose-`uname -s`-`uname -m`"
    wget -q "https://github.com/docker/compose/releases/download/v2.0.1/$COMPOSE_VERSION"
    chmod +x $COMPOSE_VERSION
    sudo mv $COMPOSE_VERSION /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
}

install_ngrok() {
    if check_installed ngrok; then
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
    echo "INSTALL LOG: LOADING SSH KEYS"
    read -p "Bitwarden ssh key name [empty for ssh-keygen]: " BITWARDEN_LOAD_KEYS
    if [ ! -z "$BITWARDEN_LOAD_KEYS" ]; then
	mkdir ~/.ssh
        if [ -z "$BITWARDEN_SERVER_URL" ]; then
        	read -p "Bitwarden server: " BITWARDEN_SERVER_URL
        fi
        sudo npm install -g @bitwarden/cli
        bw config server "$BITWARDEN_SERVER_URL"
        local BITWARDEN_LOGIN_OUTPUT=`bw login "$BITWARDEN_EMAIL" "$BITWARDEN_PASSWORD"`
        `echo "$BITWARDEN_LOGIN_OUTPUT" | grep BW_SESSION= -m 1 | sed "s/$ //" | sed "s/\"//g"`
        local SSH_KEY_INFO=`bw get item $BITWARDEN_SSH_KEY_NAME`
        echo $SSH_KEY_INFO | jq ".fields[] | select((.name == \"id_rsa.pub\")).value" -r > "$HOME/.ssh/id_rsa.pub"
        echo $SSH_KEY_INFO | jq ".notes" -r > "$HOME/.ssh/id_rsa"
        sudo npm uninstall -g @bitwarden/cli
        rm -rf ~/.config/Bitwarden\ CLI/
    else
        ssh-keygen -b 2048 -t rsa -f "$HOME/.ssh/id_rsa" -q -N ""
    fi
}

git_login() {
    echo "INSTALL LOG: SETTING UP GIT USERNAME"
    git config --global user.email $GIT_EMAIL
    git config --global user.name $GIT_USERNAME
}

install_pycharm() {
    if check_installed pycharm.sh; then
        return
    fi
    echo "INSTALL LOG: INSTALLING PYCHARM"
    wget -q "https://download.jetbrains.com/python/pycharm-community-2021.2.2.tar.gz"
    wget -q "https://download.jetbrains.com/python/pycharm-community-2021.2.2.tar.gz.sha256"
    if [ "`cat pycharm-community-2021.2.2.tar.gz.sha256 | awk '{print $1}'`" == "`sha256sum pycharm-community-2021.2.2.tar.gz | awk '{print $1}'`" ]; then
    	sudo tar xzf pycharm-*.tar.gz -C /opt/
        if check_installed zsh; then
    	    echo "export PATH=$PATH:/opt/pycharm-community-2021.2.2/bin/" >> ~/.zprofile
        else
    	    echo "export PATH=$PATH:/opt/pycharm-community-2021.2.2/bin/" >> ~/.profile
        fi
    else
    	echo "INSTALL LOG: Pycharm install error: sha256 mismatch"
    fi
    rm -rf pycharm-community-2021.2.2.tar.gz*
}

install_vscode() {
    echo "INSTALL LOG: INSTALLING VS CODE"
    snap install codium --classic
    
    codium --install-extension octref.vetur
    codium --install-extension dbaeumer.vscode-eslint
    codium --install-extension vscodevim.vim
    codium --install-extension ms-python.python
    codium --install-extension golang.go
    codium --install-extension ms-azuretools.vscode-docker
}

install_desktop_tools() {
    echo "INSTALL LOG: INSTALLING DESKTOP TOOLS"
    wget -qO - https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    
    install_packages ktorrent gnome-tweak-tool gparted telegram-desktop spotify-client vlc
}

repo_origin() {
    git remote remove origin
    git remote add origin git@github.com:$GIT_USERNAME/linux_configs.git
}

all() {
    $INSTALL_UPGRADE
    
    install_base_tools
    install_npm
    git_login
    
    install_python
    install_vim
    install_zsh
    install_tmux
    
    install_docker
    install_docker_compose
    install_golang
    install_tldr
    install_ngrok
    
    install_pycharm
    install_vscode
    install_desktop_tools
}

if [[ ! -z "`declare -f install_$1`" ]]; then
    "install_$1"
elif [[ ! -z $1 &&  ! -z "`declare -f $1`" ]]; then
    "$1"
else
    echo "INSTALL LOG: $1 is not a known install script"
    exit 1
fi
