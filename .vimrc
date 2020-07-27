set nocompatible              " required
filetype off                  " required

set nu
set relativenumber
set wrap linebreak nolist

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

Plugin 'flazz/vim-colorschemes'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-colorscheme-switcher'

Plugin 'shime/vim-livedown'

call vundle#end()            " required
filetype plugin indent on    " required

Bundle 'Valloric/YouCompleteMe'

colorscheme 256-jungle

set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
set foldmethod=indent
set foldlevel=99

noremap <leader>\ :update<CR>

" Enable folding with the spacebar
nnoremap <space> za

nnoremap <C-M> :LivedownToggle<CR>
