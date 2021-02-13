set nocompatible
set encoding=utf-8
set ignorecase
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Allowing fzf to see the fzf tool
set rtp+=/usr/local/opt/fzf

" let Vundle manage Vundle, required
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'w0rp/ale'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/nerdtree'
Plugin 'junegunn/vim-easy-align'
Plugin 'vim-airline/vim-airline'
Plugin 'junegunn/fzf.vim'
Plugin 'airblade/vim-rooter'
Plugin 'jiangmiao/auto-pairs'
Plugin 'JamshedVesuna/vim-markdown-preview'
Plugin 'Yggdroot/indentLine'
Plugin 'junegunn/goyo.vim'
Plugin 'fatih/vim-go'
let vim_markdown_preview_github=1
let g:gitgutter_async=0
" The following are examples of different formats supported.
" Keep Plugin commands beuween vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"

" Settings for Ruby / Command-T Plugin
" set rubydll=/usr/local/lib/libruby.2.5.1.dylib
" set luadll=/usr/local/Cellar/lua52/5.2.1/lib/liblua.dylib

syntax on
nnoremap <leader>sr :syntax sync fromstart<CR>
set number
let mapleader = ","
colorscheme onedark
set tabstop=2
set expandtab
set shiftwidth=2
set showcmd
set cursorline
set showmatch
set incsearch
set hlsearch
set rnu
set autoindent
set smartindent
set completeopt-=preview
set clipboard=unnamed
set updatetime=400
set list listchars=tab:»·,trail:·
set backspace=indent,eol,start
nnoremap dD ""dd
nnoremap j gj
nnoremap k gk
nnoremap B ^
nnoremap E $
nnoremap WW :w! <CR>
nnoremap WQ :wq <CR>
nnoremap QQ :q! <CR>
nnoremap <C-j> 10jzz
nnoremap <C-k> 10kzz
nnoremap <C-l> :noh<CR>
imap jj <Esc>
execute pathogen#infect()

" Using Tabs
nnoremap <C-w><C-w> gt
nnoremap <C-w>w gT
nnoremap <C-w><C-n> :tabnew<CR>

" Pane sizing
nnoremap <C-w>, 5<C-w><
nnoremap <C-w>. 5<C-w>>

" Terminal control
nnoremap :tt :terminal<CR>

" fzf.vim
nnoremap <leader>l :GFiles<CR>
nnoremap <leader>L :Files<CR>
nnoremap <leader>bu :Buffers<CR>
nnoremap <leader>f :Ag<CR>
nnoremap <leader>c :Commits<CR>
nnoremap <leader>F
  \ :call fzf#vim#ag('', fzf#vim#with_preview({'options': ['--query', expand('<cword>')]}))<cr>

" Vim Fugitive
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>gre :Gread<CR>
nnoremap <leader>gc :Gcommit -m "
nnoremap <leader>gC :Gcommit --amend --no-edit<CR>
nnoremap <leader>gst :Gstatus<CR>
nnoremap <leader>gp :Gpush origin HEAD<CR>
nnoremap <leader>gP :Gpush origin HEAD -f<CR>
nnoremap <leader>gd :Gvdiff<CR>
nnoremap gdh :diffget //2<CR>
nnoremap gdl :diffget //3<CR>

" Removing search highlight when done using it"
nnoremap ss :noh<CR>

" enbale spelling
nnoremap <leader>ss :setlocal spell spelllang=en_us<CR>
nnoremap <leader>sf z=1<CR><CR>

" Goyo for blogging
nnoremap goyo :Goyo <CR>

" NERDTree Stuff
let NERDTreeShowHidden=1
call pathogen#helptags()
nmap - :NERDTreeToggle<CR>
" au VimEnter *  NERDTree

" Operating on a complete search match
xnoremap * :<C-u>call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

"TypeScript YCM
nnoremap <leader>gtd :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>dd :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>fi :YcmCompleter FixIt<CR>
nmap <leader>ygt :YcmCompleter GoTo<CR>
nmap <leader>yo :YcmCompleter OrganizeImports<CR>
nmap <leader>yr :YcmCompleter RefactorRename<SPACE><C-R><C-W>
nmap <leader>rr :YcmCompleter RefactorRename<SPACE><C-R><C-W>

"Ale
nmap <silent> [e <Plug>(ale_previous_wrap)
nmap <silent> ]e <Plug>(ale_next_wrap)

"Pretty print JSON
nmap <leader>ppj :%!python -m json.tool<CR>

"Copy function below
nmap <leader>yyb V}y}p<CR>

"Delete current work and paste
nmap <leader>ppw viwp<CR>

"MiUsing TabUsing TabUsing Tabs
command! Q q " Bind :Q to :q
command! W w
command! WQ wq
command! Wq wq
command! Qall qall
command! QA qall
command! E e
cabbrev ew :wq
cabbrev qw :wq

" Widescreen - bring code to 2/3 screen towards the middle
function! ComeCloser()
  :vnew<CR>
  :vertical resize 50
  :wincmd l
endfunc
nnoremap <C-w>b :call ComeCloser()<CR>

function s:VSetSearch()
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" Delete trailing white space on save
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
au BufWrite * silent call DeleteTrailingWS()

" Simple re-format for minified Javascript
command! UnMinify call UnMinify()
function! UnMinify()
    %s/{\ze[^\r\n]/{\r/g
    %s/){/) {/g
    %s/};\?\ze[^\r\n]/\0\r/g
    %s/;\ze[^\r\n]/;\r/g
    %s/[^\s]\zs[=&|]\+\ze[^\s]/ \0 /g
    normal ggVG=
endfunction

" Pane Zoom
func! PaneZoom()
  res 100
  vert res 1000
endfunc
nnoremap <C-w>z :call PaneZoom()<CR>

autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow
