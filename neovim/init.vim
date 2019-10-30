" plugins
call plug#begin('~/AppData/Local/nvim/plugged')
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' } 
Plug 'rakr/vim-one'
Plug 'arcticicestudio/nord-vim'
Plug 'tpope/vim-fugitive', { 'on': ['GStatus', 'Gdiffsplit'] }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'itchyny/lightline.vim'
Plug 'justinmk/vim-sneak'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }
Plug 'OmniSharp/omnisharp-vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'ptzz/lf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

colorscheme nord

" if hidden is not set, TextEdit might fail.
set hidden
" Better display for messages
set cmdheight=1
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes
set termguicolors
let g:NERDTreeMinimalUI = 1
set inccommand=nosplit

inoremap hh <ESC>

" for searching
set hlsearch
set incsearch " enable incremental search
set ignorecase " defaults to ignore case
set smartcase " search will be case sensitive if search pattern contains upper case character

" use system clipboard always
set clipboard=unnamed
set tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab

" CTRL-Tab is next tab
noremap <C-Tab> :<C-U>tabnext<CR>
cnoremap <C-Tab> <C-C>:tabnext<CR>

" CTRL-SHIFT-Tab is previous tab
noremap <C-S-Tab> :<C-U>tabprevious<CR>
cnoremap <C-S-Tab> <C-C>:tabprevious<CR>

nnoremap <A-f> :Files<CR>
nnoremap <A-b> :Buffers<CR>
nnoremap <C-f> :Rg 
filetype plugin indent on


" to escape
imap hh <ESC> 
nmap <A-c> <C-W>w
nmap <C-S> :w<cr>
vmap <C-S> <esc>:w<cr>
imap <C-S> <esc>:w<cr>
map <A-r> *Ncgn

tnoremap hh <C-\><C-n>

map ,, :
map - :
set relativenumber
set nu
set cursorline

" leader mapping
let mapleader="\<Space>"
map <space>q :q<CR>
map <space>w :w!<CR>
map <space>x :q!<CR>
map <space>e :e <C-R>=expand('%:p:h') . '\'<CR>
map <space><space> <C-^>

set list
set listchars=tab:>-

" ===== coc.vim settings ========
" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

" session management
map <F8> :mksession! c:\vimsession\<C-D>
map <F7> :source c:\vimsession\<C-D>

