call plug#begin('~/AppData/Local/nvim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'rakr/vim-one'
Plug 'arcticicestudio/nord-vim'
Plug 'iCyMind/NeoSolarized'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'justinmk/vim-sneak'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'OmniSharp/omnisharp-vim'
call plug#end()
" -------------------------------------------------------------------------------------------------
" coc.nvim default settings
" -------------------------------------------------------------------------------------------------

" if hidden is not set, TextEdit might fail.
set hidden
" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes
" let $FZF_DEFAULT_COMMAND =  "find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"
" let $FZF_DEFAULT_OPTS=' --color=dark --color=fg:15,bg:-1,hl:1,fg+:#ffffff,bg+:0,hl+:1 --color=info:0,prompt:0,pointer:12,marker:4,spinner:11,header:-1 --layout=reverse  --margin=1,4'
"let $FZF_DEFAULT_OPTS=' --color=dark --color=fg:15,bg:-1,hl:1,fg+:#ffffff,bg+:0,hl+:1 --color=info:0,prompt:0,pointer:12,marker:1,spinner:0,header:-1 --layout=reverse  --margin=1,2'
"let $FZF_DEFAULT_OPTS=' --layout=reverse --color=info:0,header:-1,prompt:0,marker:1,pointer:5'
" let g:fzf_layout = { 'window': 'call FloatingFZF()' }
" let g:fzf_layout = { 'window': 'call FloatingFZF()' }

"function! FloatingFZF()
  "let buf = nvim_create_buf(v:false, v:true)
  "call setbufvar(buf, '&signcolumn', 'no')
"
  "let height = float2nr(10)
  "let width = float2nr(80)
  "let horizontal = float2nr((&columns - width) / 2)
  "let vertical = 2
"
  "let opts = {
        "\ 'relative': 'editor',
        "\ 'row': vertical,
        "\ 'col': horizontal,
        "\ 'width': width,
        "\ 'height': height,
        "\ 'style': 'minimal'
        "\ }
"
  "call nvim_open_win(buf, v:true, opts)
"endfunction
colorscheme nord
set background=dark " for the light version
let g:airline_theme='one'
let g:one_allow_italics = 1
" let g:OmniSharp_server_path='E:\tools\omnisharp\OmniSharp.exe'
" let g:OmniSharp_proc_debug = 1let g:OmniSharp_server_stdio = 1let g:OmniSharp_server_stdio = 1
let g:OmniSharp_server_stdio = 1
" let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Note, the above line is ignored in Neovim 0.1.5 above, use this line instead.
set termguicolors
let g:NERDTreeMinimalUI = 1
"let NERDTreeDirArrows = 1
set inccommand=nosplit
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
inoremap hh <ESC>

" for searching
set hlsearch
set incsearch " enable incremental search
set ignorecase " defaults to ignore case
set smartcase " search will be case sensitive if search pattern contains upper case character

" use system clipboard always
set clipboard=unnamed
set tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab

" line movement
nnoremap <A-j> :vsc Edit.MoveSelectedLinesDown<CR>
nnoremap <A-k> :vsc Edit.MoveSelectedLinesUp<CR>
inoremap <A-Down> <C-o>:vsc Edit.MoveSelectedLinesDown<CR>
inoremap <A-Up> <C-o>:vsc Edit.MoveSelectedLinesUp<CR>
vnoremap <A-j> :vsc Edit.MoveSelectedLinesDown<CR>
vnoremap <A-k> :vsc Edit.MoveSelectedLinesUp<CR>
" CTRL-Tab is next tab
noremap <C-Tab> :<C-U>tabnext<CR>
cnoremap <C-Tab> <C-C>:tabnext<CR>
" CTRL-SHIFT-Tab is previous tab
noremap <C-S-Tab> :<C-U>tabprevious<CR>
cnoremap <C-S-Tab> <C-C>:tabprevious<CR>
" undo/redo
noremap <C-z> :vsc Edit.Undo<CR>
noremap <C-y> :vsc Edit.Redo<CR>

nnoremap <A-f> :Files<CR>
nnoremap <A-b> :Buffers<CR>
nnoremap <C-f> :Rg 
filetype plugin indent on

let mapleader="\<Space>"

" commenting
nnoremap <Leader>cc :vsc Edit.CommentSelection<CR>
nnoremap <Leader>cu :vsc Edit.UncommentSelection<CR>
vnoremap <Leader>cc :vsc Edit.CommentSelection<CR>
vnoremap <Leader>cu :vsc Edit.UncommentSelection<CR>

" navigation in insert mode, not working 
inoremap <A-j> <Down>
inoremap <A-k> <Up>
inoremap <A-h> <Left>
inoremap <A-l> <Right>
inoremap <A-b> <b>
inoremap <A-w> <w>

" to escape
imap hh <ESC> 
nmap <A-c> <C-W>w
nmap <C-S> :w<cr>
vmap <C-S> <esc>:w<cr>
imap <C-S> <esc>:w<cr>
tnoremap hh <C-\><C-n>
map ,, :
" test
"noremap <C-f> :vsc Edit.Find<CR>
