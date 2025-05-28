vim9script

export def setup()
    # Misc
    source $VIMRUNTIME/defaults.vim
    colorscheme habamax
    language messages en_US

    # Key mapping
    g:mapleader = ' '
    cnoremap <C-v> <C-r>*
    inoremap <C-U> <C-G>u<C-U>
    nnoremap * *N
    nnoremap <C-d> <C-d>zz
    nnoremap <C-f> <C-u>zz
    nnoremap <C-p> :find *
    nnoremap <C-q> :q<CR>
    nnoremap <C-s> :%s/\s\+$//e<bar>w<CR>
    nnoremap <F2> :%s/\C\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>
    nnoremap <M-j> :m .+1<CR>==
    nnoremap <M-k> :m .-2<CR>==
    nnoremap <leader>vim :vs $MYVIMRC<CR>
    nnoremap K i<CR><Esc>
    nnoremap O O<Space><BS><Esc>
    nnoremap gd <C-]>
    nnoremap go "0yi):!start <C-r>0<CR>
    nnoremap j gj
    nnoremap k gk
    nnoremap o o<Space><BS><Esc>
    noremap H g^
    noremap L g_
    vnoremap / "-y/<C-r>-<CR>N
    vnoremap <C-d> <C-d>zz
    vnoremap <C-f> <C-u>zz
    vnoremap <D-j> :m '>+1<CR>gv=gv
    vnoremap <D-k> :m '<-2<CR>gv=gv
    vnoremap <F2> "-y:%s/<C-r>-\C/<C-r>-/g<Left><Left>
    vnoremap <M-j> :m '>+1<CR>gv=gv
    vnoremap <M-k> :m '<-2<CR>gv=gv
    vnoremap <leader>ss :sort<CR>

    # Options
    set autoindent
    set autoread
    set background=dark
    set belloff=all
    set breakindent
    set clipboard=unnamed
    set colorcolumn=81,101
    set complete=.,w,b,u,t
    set completeopt=menuone,longest,preview
    set cursorcolumn
    set cursorline
    set expandtab
    set fileformat=unix
    set grepformat=%f:%l:%c:%m,%f:%l:%m
    set guifont=DepartureMono\ Nerd\ Font\ Mono:h11
    set hlsearch
    set ignorecase
    set infercase
    set iskeyword=@,48-57,_,192-255,-
    set laststatus=2
    set list
    set listchars=tab:-->,trail:~,nbsp:␣
    set nofoldenable
    set noswapfile
    set nowrap
    set number
    set path+=**
    set pumheight=50
    set relativenumber
    set shiftwidth=4
    set shortmess=flnxtocTOCI
    set signcolumn=yes
    set smartcase
    set smarttab
    set softtabstop=4
    set statusline=%f:%l:%c\ %m%r%h%w%q%y\ %{FugitiveStatusline()}\ [enc=%{&fileencoding}]\ [%{&ff}]
    set tabstop=4
    set termguicolors
    set textwidth=100
    set undodir=expand('$HOME/.vim/undo/')
    set undofile
    set viminfofile=$HOME/.vim/.viminfo
    set wildignorecase
    set wildoptions=pum
end
