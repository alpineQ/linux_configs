set nocompatible              " required
filetype off                  " required

set nu
set relativenumber

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

Plugin 'flazz/vim-colorschemes'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-colorscheme-switcher'

Plugin 'vim-airline/vim-airline'
Plugin 'ryanoasis/vim-devicons'

Plugin 'shime/vim-livedown'

call vundle#end()            " required
filetype plugin indent on    " required

Bundle 'Valloric/YouCompleteMe'

colorscheme 256-jungle

"let g:airline_powerline_fonts = 1 "Включить поддержку Powerline шрифтов
"let g:airline#extensions#keymap#enabled = 0 "Не показывать текущий маппинг
"let g:airline_section_z = "\ue0a1:%l/%L Col:%c" "Кастомная графа положения курсора
"let g:Powerline_symbols='unicode' "Поддержка unicode
"let g:airline#extensions#xkblayout#enabled = 0

"set guifont=Operator\Mono\ weight=350\ 10

set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

nnoremap <C-M> :LivedownToggle<CR>
