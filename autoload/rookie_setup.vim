scriptencoding utf-8

function! rookie_setup#Setup() abort
    " Misc
    source $VIMRUNTIME/defaults.vim
    colorscheme habamax
    language messages en_US

    " Key mapping
    let g:mapleader = ' '
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
    vnoremap <D-j> :m ' >+1<CR>gv=gv
    vnoremap <D-k> :m ' <-2<CR>gv=gv
    vnoremap <F2> "-y:%s/<C-r>-\C/<C-r>-/g<Left><Left>
    vnoremap <M-j> :m ' >+1<CR>gv=gv
    vnoremap <M-k> :m ' <-2<CR>gv=gv
    vnoremap <leader>ss :sort<CR>

    " Options
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
    let &undodir = expand('$HOME/.vim/undo/')
    set undofile
    let &viminfofile = expand('$HOME/.vim/.viminfo')
    set wildignorecase
    set wildoptions=pum

    " Plugin keymaps
    xnoremap <M-d>   <Plug>(textmanip-duplicate-down)
    nnoremap <M-d>   <Plug>(textmanip-duplicate-down)
    xnoremap <M-D>   <Plug>(textmanip-duplicate-up)
    nnoremap <M-D>   <Plug>(textmanip-duplicate-up)
    xnoremap <C-j>   <Plug>(textmanip-move-down)
    xnoremap <C-k>   <Plug>(textmanip-move-up)
    xnoremap <C-h>   <Plug>(textmanip-move-left)
    xnoremap <C-l>   <Plug>(textmanip-move-right)
    nnoremap <F6>    <Plug>(textmanip-toggle-mode)
    xnoremap <F6>    <Plug>(textmanip-toggle-mode)
    xnoremap <Down>  <Plug>(textmanip-move-down-r)
    xnoremap <Left>  <Plug>(textmanip-move-left-r)
    xnoremap <Right> <Plug>(textmanip-move-right-r)

    nnoremap <C-y>   :NERDTreeToggle<CR>
    nnoremap <F10>   :copen <bar> AsyncRun cargo<Space>

    " Set rg keymaps
    call rookie_rg#Setup()

    " Set lsp keymaps
    call rookie_lsp#Setup()

    " Set extra keymaps
    call rookie_setup#SetupKeymaps()
endfunction


function! rookie_setup#SetupKeymaps() abort
    if !get(g:, 'rookie_toys_setup_keymap_enable', 0)
        return
    endif

    "===============================================================================
    " Keys
    "===============================================================================
    let g:mapleader = ' '
    let g:maplocalleader = ' '
    cnoremap <C-v> <C-r>*
    nnoremap * *Nzz
    nnoremap <C-d> <C-d>zz
    nnoremap <C-f> <C-u>zz
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
    vnoremap <C-d> <C-d>zz
    vnoremap <C-f> <C-u>zz
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
