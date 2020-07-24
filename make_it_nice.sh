cp .bashrc ~
sudo apt install -y build-essential cmake vim python3-dev git tmux docker docker-compose nodejs npm

ssh-keygen -b 2048 -t rsa -q -N ""
git config --global user.email "mk_dev@mail.ru"
git config --global user.username "alpineQ"

sudo usermod -aG docker $USER

echo Setting up vim stuff
cp .vimrc ~
git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim
python3 ~/.vim/bundle/YouCompleteMe/install.py
npm install -g livedown

echo Setting up tmux stuff
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
