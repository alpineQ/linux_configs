cp .bashrc ~
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential cmake vim python3-dev python3-pip python-is-python3 git tmux docker docker-compose nodejs npm xclip golang ktorrent net-tools gnome-tweak-tool
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

if [ ! -d "$HOME/.ssh" ]; then
    ssh-keygen -b 2048 -t rsa -f "/home/$USER/.ssh/id_rsa" -q -N ""
fi

git config --global user.email "mk_dev@mail.ru"
git config --global user.username "alpineQ"

sudo usermod -aG docker $USER

echo "VIM INSTALLATION"
cp .vimrc ~
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim -q
sudo npm install -g livedown
echo "Make :PluginInstall" > vim.tmp
(
cd ~/.vim/bundle/YouCompleteMe || exit
python3 install.py
)
vim vim.tmp
rm vim.tmp

echo "TMUX INSTALLATION"
git clone https://github.com/gpakosz/.tmux.git -q
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local ~

echo "PRETTY WINDOW APPS INSTALLATION"
sudo snap install pycharm-community --classic
sudo snap install code --classic
sudo snap install wps-office-all-lang-no-internet
sudo snap install spotify
sudo snap install telegram-desktop
sudo snap install vlc


echo "VS CODE EXTENSIONS INSTALLATION"
code --install-extension octref.vetur
code --install-extension dbaeumer.vscode-eslint
code --install-extension vscodevim.vim
code --install-extension ms-python.python
code --install-extension golang.go
code --install-extension ms-azuretools.vscode-docker
