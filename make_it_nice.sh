cp .bashrc ~
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential cmake vim python3-dev git tmux docker docker-compose nodejs npm xclip golang ktorrent net-tools

if [ ! -d "$HOME/.ssh" ]; then
    ssh-keygen -b 2048 -t rsa -q -N ""
fi

git config --global user.email "mk_dev@mail.ru"
git config --global user.username "alpineQ"

sudo usermod -aG docker $USER

echo Setting up vim stuff
cp .vimrc ~
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
sudo npm install -g livedown
echo "Make :PluginInstall" > vim.tmp
(
cd ~/.vim/bundle/YouCompleteMe || exit
python3 install.py
)
vim vim.tmp
rm vim.tmp

echo Setting up tmux stuff
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local ~

sudo snap install pycharm-community --classic
sudo snap install code --classic
code --install-extension octref.vetur
code --install-extension dbaeumer.vscode-eslint
code --install-extension vscodevim.vim
code --install-extension ms-python.python
code --install-extension golang.go
code --install-extension ms-azuretools.vscode-docker
sudo snap install telegram-desktop
sudo snap install wps-office-all-lang-no-internet
sudo snap install spotify
