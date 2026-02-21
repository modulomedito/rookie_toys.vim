scriptencoding utf-8

function! rookie_setup#Setup() abort
    " Default
    if !exists('g:rookie_toys_setup_enable')
        let g:rookie_toys_setup_enable = 0
    endif
    if !exists('g:rookie_toys_setup_option_enable')
        let g:rookie_toys_setup_option_enable = 1
    endif
    if !exists('g:rookie_toys_setup_keymap_enable')
        let g:rookie_toys_setup_keymap_enable = 1
    endif

    " Execute setup
    if get(g:, 'rookie_toys_setup_enable', 0)
        finish
    endif
    if get(g:, 'rookie_toys_setup_option_enable', 1)
        call rookie_setup#SetupOptions()
    endif
    if get(g:, 'rookie_toys_setup_keymap_enable', 1)
        call rookie_setup#SetupKeymaps()
    endif
endfunction

function! rookie_setup#SetupOptions() abort
    source $VIMRUNTIME/defaults.vim
    set ambiwidth=double
    set autoindent
    set autoread
    set background=dark
    set belloff=all
    set breakindent
    set clipboard=unnamed
    set cmdheight=2
    set colorcolumn=81,101,121
    set complete=.,w,b,u,t
    set completeopt=menuone,noselect,popup
    set cursorcolumn
    set cursorline
    set expandtab
    set fileformat=unix
    set formatoptions+=mB
    set grepformat=%f:%l:%c:%m,%f:%l:%m
    set guifont=Cascadia\ Code:h9
    set guioptions+=k
    set guioptions-=L
    set guioptions-=T
    set guioptions-=e
    set guioptions-=m
    set guioptions-=r
    set hlsearch
    set ignorecase
    set infercase
    set iskeyword=@,48-57,_,192-255,-
    set laststatus=2
    set list
    set listchars=tab:-->,trail:~,nbsp:␣
    set modeline
    set modelines=5
    set nobackup
    set nofoldenable
    set noswapfile
    set nowrap
    set nowritebackup
    set number
    set path+=**
    set pumheight=50
    set relativenumber
    set sessionoptions+=tabpages,globals
    set shiftwidth=4
    set shortmess=flnxtocTOI
    set signcolumn=yes
    set smartcase
    set smarttab
    set softtabstop=4
    set splitbelow
    set splitright
    set statusline+=\ %{FugitiveStatusline()}
    set statusline=%f:%l:%c\ %m%r%h%w%q%y\ [enc=%{&fileencoding}]\ [%{&ff}]
    set tabstop=4
    set termguicolors
    set textwidth=100
    set undofile
    set wildcharm=<Tab>
    set wildignorecase
    set wildoptions=pum
    if has('unix')
        set undodir=expand('$HOME/.vim/undo/')
        set viminfofile=$HOME/.vim/.viminfo
    else
        set undodir=expand('$HOME/vimfiles/undo/')
        set viminfofile=$HOME/vimfiles/_viminfo
    endif
    if has('gui_running')
        set columns=107
        set lines=25
    endif
endfunction

function! rookie_setup#SetupKeymaps() abort
    let g:mapleader = ' '
    let g:maplocalleader = ' '
    cnoremap <C-v> <C-r>*
    nnoremap * *Nzz
    nnoremap <C-j> :m .+1<CR>==
    nnoremap <C-k> :m .-2<CR>==
    nnoremap <C-p> :find *
    nnoremap <F2> :%s/\C\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>
    nnoremap <M-Down> :m .+1<CR>==
    nnoremap <M-Up> :m .-2<CR>==
    nnoremap <M-i> :b<Space><Tab>
    nnoremap <M-j> :m .+1<CR>==
    nnoremap <M-k> :m .-2<CR>==
    nnoremap <M-u> :b<Space><Tab><S-Tab><S-Tab>
    nnoremap <silent> + :vertical resize +2<CR>
    nnoremap <silent> <C-M-PageDown> :tabmove +1<CR>
    nnoremap <silent> <C-M-PageUp> :tabmove -1<CR>
    nnoremap <silent> <C-S-Tab> gT
    nnoremap <silent> <C-S-t> :tabnew<CR>
    nnoremap <silent> <C-Tab> gt
    nnoremap <silent> <C-q> :q<CR>
    nnoremap <silent> <C-s> m6:%s/\s\+$//e<Bar>w<CR>`6zz:noh<CR>
    nnoremap <silent> <C-w>i gt
    nnoremap <silent> <C-w>u gT
    nnoremap <silent> <F10> :cnext<CR>
    nnoremap <silent> <F11> :cclose<CR>
    nnoremap <silent> <F8> :copen<CR>
    nnoremap <silent> <F9> :cprevious<CR>
    nnoremap <silent> <leader>clr :%bd<bar>e #<bar>normal `<CR>
    nnoremap <silent> <leader>vim :vs $MYVIMRC<CR>
    nnoremap <silent> _ :vertical resize -2<CR>
    nnoremap K i<CR><Esc>
    nnoremap O O<Space><BS><Esc>
    nnoremap gd <C-]>
    nnoremap go "0yi):!start <C-r>0<CR>
    nnoremap j gj
    nnoremap k gk
    nnoremap o o<Space><BS><Esc>
    noremap <leader>P "0P
    noremap <leader>p "0p
    noremap H g^
    noremap L g_
    vnoremap / "-y/<C-r>-<CR>N
    vnoremap <C-j> :m '><+1<CR>gv=gv
    vnoremap <C-k> :m '<-2<CR>gv=gv
    vnoremap <F2> "-y:%s/<C-r>-\C/<C-r>-/g<Left><Left>
    vnoremap <M-Down> :m '><+1<CR>gv=gv
    vnoremap <M-Up> :m '<-2<CR>gv=gv
    vnoremap <M-j> :m '><+1<CR>gv=gv
    vnoremap <M-k> :m '<-2<CR>gv=gv
    vnoremap <leader>ss :sort<CR>
    vnoremap <silent> <C-b> "-di**<C-r>-**<Esc>
    vnoremap p pgv<Esc>
    vnoremap y ygv<Esc>
    nnoremap <silent> <leader>obs
        \ :wa<CR>
        \:silent !git pull<CR>
        \:silent !git add .<CR>
        \:silent !git commit -m "update by vim"<CR>
        \:silent !git push<CR>
        \:G fetch
        \<Bar>call timer_start(1500, {-> execute('RookieGitGraph')})
        \<Bar>G<CR>
endfunction
