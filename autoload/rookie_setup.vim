scriptencoding utf-8

function! rookie_setup#Setup() abort
    " Default
    if !exists('g:rookie_toys_setup_enable')
        let g:rookie_toys_setup_enable = 0
    endif
    if !exists('g:rookie_toys_default_setup_option')
        let g:rookie_toys_default_setup_option = 1
    endif
    if !exists('g:rookie_toys_setup_keymap_enable')
        let g:rookie_toys_setup_keymap_enable = 1
    endif
    if !exists('g:rookie_toys_default_setup_abbr')
        let g:rookie_toys_default_setup_abbr = 1
    endif
    if !exists('g:rookie_toys_setup_plugin_enable')
        let g:rookie_toys_setup_plugin_enable = 1
    endif
    if !exists('g:rookie_toys_setup_autocmd_enable')
        let g:rookie_toys_setup_autocmd_enable = 1
    endif
    if !exists('g:rookie_toys_setup_user_command_enable')
        let g:rookie_toys_setup_user_command_enable = 1
    endif
    if !exists('g:rookie_toys_default_setup_rg')
        let g:rookie_toys_default_setup_rg = 1
    endif
    if !exists('g:rookie_toys_syntax_highlight_enable')
        let g:rookie_toys_syntax_highlight_enable = 1
    endif

    " Execute setup
    if get(g:, 'rookie_toys_setup_enable', 1)
        if get(g:, 'rookie_toys_setup_keymap_enable', 1)
            call rookie_setup#SetupKeymaps()
        endif
        if get(g:, 'rookie_toys_setup_plugin_enable', 1)
            call rookie_plugins#SetupPlugins()
        endif
        if get(g:, 'rookie_toys_setup_autocmd_enable', 1)
            call rookie_setup#SetupAutocmd()
        endif
        if get(g:, 'rookie_toys_setup_user_command_enable', 1)
            call rookie_setup#SetupUserCommand()
        endif
    endif

    if get(g:, 'rookie_toys_default_setup_option', 1)
        call rookie_setup#SetupOptions()
    endif
    if get(g:, 'rookie_toys_default_setup_rg', 1)
        call rookie_rg#Setup()
    endif
    if get(g:, 'rookie_toys_default_setup_abbr', 1)
        call rookie_setup#SetupAbbr()
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
    " nnoremap gd <C-]>
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

function! rookie_setup#SetupAutocmd() abort
    autocmd! FileType python
        \ nnoremap <buffer> <leader><F10> :copen <bar> AsyncRun python<Space>%<Tab>
    autocmd! FileType rust
        \ nnoremap <buffer> <leader><F10> :copen <bar> AsyncRun cargo<Space>
        \|nnoremap <buffer> <leader><F9> :RookieRustTestFunctionUnderCursor<CR>
        \|call CocAction('diagnosticToggle', 0)
    autocmd! FileType typescript
        \ nnoremap <buffer> <F10> :copen <bar> AsyncRun npm run build<CR>
        \|nnoremap <silent><buffer> <S-M-f> <Plug>(coc-format)
    autocmd! FileType ps1
        \ setlocal iskeyword+=:
    autocmd! FileType c
        \ setlocal iskeyword-=-
        \|setlocal textwidth=79
        \|setlocal commentstring=//%s
        \|nnoremap <silent><buffer> <C-s> :let g:my_pos = getpos('.')<CR>
        \<Plug>(coc-format)<Bar>m6:%s/\s\+$//e<Bar>w<CR>`6zz:noh<CR>
        \:if exists('g:my_pos')\|call setpos('.', g:my_pos)\|endif<CR>
        \:w<CR>
    autocmd! FileType lsl
        \ setlocal filetype=c syntax=c
    autocmd! FileType lua
        \ nnoremap <silent><buffer> <S-M-f> :call LuaFormat()<CR>
    autocmd! FileType tex
        \ setlocal textwidth=80
    autocmd! FileType help
        \ nnoremap <buffer> gd <C-]>
    autocmd! FileType markdown
        \ setlocal textwidth=79
        \|setlocal ve=all
        \|setlocal wrap
        \|nnoremap <silent><buffer> <S-M-f> :PanguAll<CR>m6:call timer_start(200, {-> execute('CocCommand markdownlint.fixAll')})<CR>
        \|vnoremap <silent><buffer> <S-M-f> :silent! RookieMarkdownLinter<CR>
        \|nnoremap <silent><buffer> <leader>fmt :PanguAll<CR>m6:CocCommand markdownlint.fixAll<CR>'6zz
        \|vnoremap <silent><buffer> <leader>fmt :silent! RookieMarkdownLinter<CR>
    autocmd! FileType git
        \ setlocal iskeyword+=- iskeyword+=/
        \|nnoremap <silent><buffer> <C-l> f)b
        \|nnoremap <silent><buffer> <C-j> :RookieGitDiffFileNext<CR>
        \|nnoremap <silent><buffer> <C-k> :RookieGitDiffFilePrevious<CR>
    autocmd! FileType gitcommit
        \ setlocal textwidth=100
        \|nnoremap <silent><buffer> <S-M-f> :PanguAll<CR>
        \|nnoremap <silent><buffer> <C-q> :q<Bar>call timer_start(1000, {-> execute('RookieGitGraph')})<CR>
    autocmd! FileType vim
        \ setlocal iskeyword-=-
    autocmd! FileType hex setlocal nostartofline | setlocal virtualedit=block
endfunction

function! rookie_setup#SetupUserCommand() abort
    command! VSC :silent !trae %:p<CR>
    command! CommentToSlash :s\/\*\+\s\+\(.*\)\*\/\/\/ \\1/g
    command! CD :let @+ = 'cd ' . getcwd() | qa
endfunction