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
    if !exists('g:rookie_toys_setup_abbr_enable')
        let g:rookie_toys_setup_abbr_enable = 1
    endif
    if !exists('g:rookie_toys_setup_plugin_enable')
        let g:rookie_toys_setup_plugin_enable = 1
    endif

    " Execute setup
    if get(g:, 'rookie_toys_setup_enable', 0)
        return
    endif
    if get(g:, 'rookie_toys_setup_option_enable', 1)
        call rookie_setup#SetupOptions()
    endif
    if get(g:, 'rookie_toys_setup_keymap_enable', 1)
        call rookie_setup#SetupKeymaps()
    endif
    if get(g:, 'rookie_toys_setup_abbr_enable', 1)
        call rookie_setup#SetupAbbr()
    endif
    if get(g:, 'rookie_toys_setup_plugin_enable', 1)
        call rookie_plugins#SetupPlugins()
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
    execute 'cnoremap <C-v> <C-r>*'
    execute 'nnoremap * *Nzz'
    execute 'nnoremap <C-j> :m .+1<CR>=='
    execute 'nnoremap <C-k> :m .-2<CR>=='
    execute 'nnoremap <C-p> :find *'
    execute 'nnoremap <F2> :%s/\C\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>'
    execute 'nnoremap <M-Down> :m .+1<CR>=='
    execute 'nnoremap <M-Up> :m .-2<CR>=='
    execute 'nnoremap <M-i> :b<Space><Tab>'
    execute 'nnoremap <M-j> :m .+1<CR>=='
    execute 'nnoremap <M-k> :m .-2<CR>=='
    execute 'nnoremap <M-u> :b<Space><Tab><S-Tab><S-Tab>'
    execute 'nnoremap <silent> + :vertical resize +2<CR>'
    execute 'nnoremap <silent> <C-M-PageDown> :tabmove +1<CR>'
    execute 'nnoremap <silent> <C-M-PageUp> :tabmove -1<CR>'
    execute 'nnoremap <silent> <C-S-Tab> gT'
    execute 'nnoremap <silent> <C-S-t> :tabnew<CR>'
    execute 'nnoremap <silent> <C-Tab> gt'
    execute 'nnoremap <silent> <C-q> :q<CR>'
    execute 'nnoremap <silent> <C-s> m6:%s/\s\+$//e<Bar>w<CR>`6zz:noh<CR>'
    execute 'nnoremap <silent> <C-w>i gt'
    execute 'nnoremap <silent> <C-w>u gT'
    execute 'nnoremap <silent> <F10> :cnext<CR>'
    execute 'nnoremap <silent> <F11> :cclose<CR>'
    execute 'nnoremap <silent> <F8> :copen<CR>'
    execute 'nnoremap <silent> <F9> :cprevious<CR>'
    execute 'nnoremap <silent> <leader>clr :%bd<bar>e #<bar>normal `<CR>'
    execute 'nnoremap <silent> <leader>vim :vs $MYVIMRC<CR>'
    execute 'nnoremap <silent> _ :vertical resize -2<CR>'
    execute 'nnoremap K i<CR><Esc>'
    execute 'nnoremap O O<Space><BS><Esc>'
    execute 'nnoremap gd <C-]>'
    execute 'nnoremap go "0yi):!start <C-r>0<CR>'
    execute 'nnoremap j gj'
    execute 'nnoremap k gk'
    execute 'nnoremap o o<Space><BS><Esc>'
    execute 'noremap <leader>P "0P'
    execute 'noremap <leader>p "0p'
    execute 'noremap H g^'
    execute 'noremap L g_'
    execute 'vnoremap / "-y/<C-r>-<CR>N'
    execute 'vnoremap <C-j> :m ''><+1<CR>gv=gv'
    execute 'vnoremap <C-k> :m ''<-2<CR>gv=gv'
    execute 'vnoremap <F2> "-y:%s/<C-r>-\C/<C-r>-/g<Left><Left>'
    execute 'vnoremap <M-Down> :m ''><+1<CR>gv=gv'
    execute 'vnoremap <M-Up> :m ''<-2<CR>gv=gv'
    execute 'vnoremap <M-j> :m ''><+1<CR>gv=gv'
    execute 'vnoremap <M-k> :m ''<-2<CR>gv=gv'
    execute 'vnoremap <leader>ss :sort<CR>'
    execute 'vnoremap <silent> <C-b> "-di**<C-r>-**<Esc>'
    execute 'vnoremap p pgv<Esc>'
    execute 'vnoremap y ygv<Esc>'
    execute 'nnoremap <silent> <leader>obs '
        \ . ':wa<CR>'
        \ . ':silent !git pull<CR>'
        \ . ':silent !git add .<CR>'
        \ . ':silent !git commit -m "update by vim"<CR>'
        \ . ':silent !git push<CR>'
        \ . ':G fetch'
        \ . '<Bar>call timer_start(1500, {-> execute(''RookieGitGraph'')})'
        \ . '<Bar>G<CR>'
endfunction

function! rookie_setup#SetupAbbr() abort
    iab xbar <C-R>=repeat('-',80)<CR><Esc>0
    iab xbui 🔧 build():[#]<Left><Left><Left><Left>
    iab xcho 🐳 chore():[#]<Left><Left><Left><Left>
    iab xdoc 📃 docs():[#]<Left><Left><Left><Left>
    iab xfea ✨ feat():[#]<Left><Left><Left><Left>
    iab xfix 🐞 fix():[#]<Left><Left><Left><Left>
    iab xini 🎉 init():[#]<Left><Left><Left><Left>
    iab xref 🦄 refactor():[#]<Left><Left><Left><Left>
    cab Gl call timer_start(1200, {-> execute('RookieGitGraph')})\|G
    cab GP silent G pull\|GG
    cab Gp silent G push\|GG
    cab Gf silent G fetch\|GG
    cab Gc silent G checkout <C-r><C-w>\|GG
    cab Gm silent G merge --ff <C-r><C-w>\|GG
    cab Gr silent G rebase <C-r><C-w>\|GG
    cab Gsi silent G stash push --include-untracked\|GG
    cab Gso silent G stash pop\|GG
    cab Gclr silent G clean -d -f -x
    cab Gtag silent G tag\|GG<Left><Left><Left>
    cab Gbdl silent G branch -d\|GG<Left><Left><Left>
    cab Gbdr silent G push origin --delete\|GG<Left><Left><Left>
    cab Gnew silent G checkout -b\|GG<Left><Left><Left>
endfunction