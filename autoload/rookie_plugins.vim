scriptencoding utf-8

function! rookie_plugins#SetupPlugins() abort
    " if exists('g:asyncrun_exit')
    "     call rookie_plugins#Setup_AsyncRun()
    " endif
    if !exists('g:rookie_toys_default_setup_nerdtree')
        let g:rookie_toys_default_setup_nerdtree = 0
    endif
    if !exists('g:rookie_toys_default_setup_vimtextmanip')
        let g:rookie_toys_default_setup_vimtextmanip = 0
    endif
    " if exists('g:textmanip_enable_mappings')
    "     call rookie_plugins#Setup_VimTextmanip()
    " endif
    if !exists('g:rookie_toys_default_setup_coc')
        let g:rookie_toys_default_setup_coc = 0
    endif
    " if exists('g:coc_status')
    "     call rookie_plugins#Setup_Coc()
    " endif
    " if exists('g:rookie_toys')
    "     call rookie_plugins#Setup_RookieToys()
    " endif
    " if exists('g:UltiSnipsExpandTrigger')
    "     call rookie_plugins#Setup_UltiSnips()
    " endif
    " if exists('g:NERDTreeGitStatusUseNerdFonts')
    "     call rookie_plugins#Setup_NerdtreeGitPlugin()
    " endif
    " if exists('g:UndotreeWinSize')
    "     call rookie_plugins#Setup_Undotree()
    " endif
    " if exists('g:loaded_vim_highlighter')
    "     call rookie_plugins#Setup_Highlighter()
    " endif
    " if exists('g:EasyAlign')
    "     call rookie_plugins#Setup_EasyAlign()
    " endif
    " if exists('g:rooter_patterns')
    "     call rookie_plugins#Setup_Rooter()
    " endif
    " if exists('g:cpp_member_variable_highlight')
    "     call rookie_plugins#Setup_CppEnhancedHighlight()
    " endif
    " if exists('g:loaded_copilot')
    "     call rookie_plugins#Setup_Copilot()
    " endif
    " if exists('g:loaded_far')
    "     call rookie_plugins#Setup_Far()
    " endif

    if g:rookie_toys_default_setup_nerdtree
        call rookie_plugins#Setup_Nerdtree()
    endif
    if g:rookie_toys_default_setup_coc
        call rookie_plugins#Setup_Coc()
    endif
    if g:rookie_toys_default_setup_vimtextmanip
        call rookie_plugins#Setup_VimTextmanip()
    endif
endfunction

function! rookie_plugins#Setup_VimTextmanip() abort
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
    xnoremap <Up>    <Plug>(textmanip-move-up-r)
    xnoremap <Down>  <Plug>(textmanip-move-down-r)
    xnoremap <Left>  <Plug>(textmanip-move-left-r)
    xnoremap <Right> <Plug>(textmanip-move-right-r)
endfunction

" Plug 'skywind3000/asyncrun.vim'
function! rookie_plugins#Setup_AsyncRun() abort
    nnoremap <F8> :AsyncRun<Space>
    nnoremap <C-F9> :AsyncStop<CR>:AsyncReset<CR>
endfunction

" Plug 'preservim/nerdtree'
function! rookie_plugins#Setup_Nerdtree() abort
    let g:NERDTreeWinSize = 40
    function! s:NTChCwd() abort
        let l:node = g:NERDTreeFileNode.GetSelected()
        if empty(l:node)
            echo 'select a node first'
            return
        endif
        try
            call l:node.path.changeToDir()
        catch /^NERDTree.PathChangeError/
            echohl WarningMsg | echom 'could not change cwd' | echohl NONE
        endtry
    endfunction
    command! -nargs=0 NTChCwd call <SID>NTChCwd()
    autocmd! FileType nerdtree nnoremap <buffer> a :call NERDTreeAddNode()<CR>
        \|nnoremap <buffer> <leader>cd :NTChCwd<CR>:NERDTreeCWD<CR>
        \|nnoremap <buffer> <C-S-e> :NERDTreeToggle<CR>
        \|nnoremap <buffer> mc :RookieNERDTreeCopy<CR>
        \|nnoremap <buffer> mP :RookieNERDTreePaste<CR>
    nnoremap <C-S-e> :NERDTreeFocus<CR>
    nnoremap <C-y> :NERDTreeToggle<CR>
    nnoremap <leader>find :NERDTreeFind<CR>
endfunction

" Plug 'neoclide/coc.nvim'
function! rookie_plugins#Setup_Coc() abort
    " Install COC extension
    "     - Markdown LSP          :CocInstall @yaegassy/coc-marksman
    "     - Markdown linter       :CocInstall coc-markdownlint
    "     - Json formatter        :CocInstall coc-json
    " Config, add below to :CocConfig
    " {
    "     "coc.preferences.formatOnSaveFiletypes": [
    "         "json"
    "     ],
    "     "clangd.semanticHighlighting": true,
    "     "coc.preferences.semanticTokensHighlights": true,
    "     "[lua][c]": {
    "         "inlayHint.enable": false
    "     },
    "     "diagnostic.enable": false,
    "     "suggest.noselect": true,
    "     "markdownlint.config": {
    "         "MD007": {
    "             "indent": 4
    "         },
    "         "MD010": {
    "             "code_blocks": false,
    "             "spaces_per_tab": 4
    "         },
    "         "MD018": false,
    "         "MD022": true,
    "         "MD031": true,
    "         "MD058": true,
    "         "MD013": {
    "             "code_blocks": false,
    "             "headings": false,
    "             "line_length": 80,
    "             "strict": true,
    "             "tables": false
    "         }
    "     }
    " }
    nnoremap <leader>rn             <Plug>(coc-rename)
    nnoremap <silent> <S-M-f>       <Plug>(coc-format)
    nnoremap <silent> <leader>gd    <C-w>v<Plug>(coc-definition)
    nnoremap <silent> <leader>lsd   :call CocAction('diagnosticToggle')<CR>
    nnoremap <silent> <leader>lsh   :CocCommand document.toggleInlayHint<CR>
    nnoremap <silent> [d            <Plug>(coc-diagnostic-prev)
    nnoremap <silent> ]d            <Plug>(coc-diagnostic-next)
    nnoremap <silent> gD            <Plug>(coc-declaration)
    nnoremap <silent> gO            :call CocAction('showOutline')<CR>
    nnoremap <silent> gd            <Plug>(coc-definition)
    nnoremap <silent> gh            :call CocAction('doHover')<CR>:call coc#float#jump()<CR>
    nnoremap <silent> gi            <Plug>(coc-implementation)
    nnoremap <silent> gr            <Plug>(coc-references)
    nnoremap <silent> gs            :call CocAction('documentSymbols')<CR>
    nnoremap <silent> gy            :call CocAction('jumpTypeDefinition')<CR>
    vnoremap <silent> <S-M-f>       <Plug>(coc-format-selected)
    inoremap <silent><expr> <CR>    coc#pum#visible() ?
                                    \ coc#pum#confirm() :
                                    \ "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
    nnoremap <silent><nowait><expr> <PageDown> coc#float#has_scroll() ? coc#float#scroll(1) : "\<PageDown>"
    nnoremap <silent><nowait><expr> <PageUp> coc#float#has_scroll() ? coc#float#scroll(0) : "\<PageUp>"
    nnoremap <silent><nowait><expr> <Esc> coc#float#has_scroll() ? coc#float#close_all() : "\<Esc>"
endfunction

" Plug 'modulomedito/rookie_toys.vim'
function! rookie_plugins#Setup_RookieToys() abort
    command! CC RookieClangdGenerate | CocRestart
    command! GD RookieGitDiff
    command! GG RookieGitGraph
    command! GGL RookieGitGraphLocal
    let g:rookie_rooter_patterns = [
        \ '.cproject', '.project', '.clang-format', '.git', 'compile_commands.json',
        \ 'Cargo.toml', 'Makefile']
    nnoremap <leader>FA :RookieTagAddFileName<CR>
    nnoremap <leader>FF :RookieTagSearchFileName<CR>
    nnoremap <leader>diff :RookieGitOpenCommitDiff<CR>
    nnoremap <leader>fa :RookieTagUpdate<CR>
    nnoremap <leader>ff :RookieTagSearch<CR>
    nnoremap <leader>fg :RookieTagSearchGlobal<CR>
    nnoremap <leader>ida :RookieGuidGenerate<CR>
    nnoremap <leader>ids :RookieGuidSearch<CR>
    nnoremap <leader>pa :RookieProjectAdd<CR>
    nnoremap <leader>pdel :RookieProjectRemove<CR>
    nnoremap <leader>pj :RookieProjectList<CR>
    nnoremap <leader>prn :RookieProjectRename<CR>
    nnoremap <leader>retab :RookieRetab<CR>
    nnoremap <silent> <leader><C-l> :RookieSlugifyLine<CR>
    nnoremap <silent> <leader>dl :RookieGitDiffJumpToChange<CR>
    nnoremap <silent> <leader>hh :RookieToggleHeaderSource<CR>
    nnoremap <silent> <leader>rrt :RookieRooterHere<CR>
    nnoremap <unique><silent> <C-d> <cmd>RookieSmoothScrollHalfPageDown<CR>
    nnoremap <unique><silent> <C-f> <cmd>RookieSmoothScrollHalfPageUp<CR>
    vnoremap <unique><silent> <C-d> <cmd>RookieSmoothScrollHalfPageDown<CR>
    vnoremap <unique><silent> <C-f> <cmd>RookieSmoothScrollHalfPageUp<CR>
    nnoremap <leader><F3> :RookieFarDo<CR>
    nnoremap <leader><F2> *:RookieFarReplace -c -w
        \ <C-r><C-w> <C-r><C-w> **/*.[ch]
        \<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
    vnoremap <leader><F2> "-y/<C-r>-<CR>N
        \"-y:RookieFarReplace -c
        \ <C-r>- <C-r>- **/*.[ch]
        \<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
endfunction

" Plug 'SirVer/ultisnips'
function! rookie_plugins#Setup_UltiSnips() abort
    let g:UltiSnipsExpandTrigger = "<tab>"
    let g:UltiSnipsJumpForwardTrigger = "<c-j>"
    let g:UltiSnipsJumpBackwardTrigger = "<c-k>"
    let g:UltiSnipsListSnippets = "<c-l>"
    if has('unix')
        let g:UltiSnipsSnippetDirectories = ['ultisnips', '~/.vim/ultisnips']
    else
        let g:UltiSnipsSnippetDirectories = ['ultisnips', '$HOME/vimfiles/ultisnips']
    endif
endfunction

" Plug 'Xuyuanp/nerdtree-git-plugin'
function! rookie_plugins#Setup_NerdtreeGitPlugin() abort
    let g:NERDTreeGitStatusUseNerdFonts = 0
endfunction

" Plug 'mbbill/undotree'
function! rookie_plugins#Setup_Undotree() abort
    nnoremap <leader>u :UndotreeToggle<CR>
    if has("persistent_undo")
        if has('win32') || has('win64')
            let target_path = expand('~/vimfiles/undo')
        else
            let target_path = expand('~/.vim/undo')
        endif
        if !isdirectory(target_path)
            call mkdir(target_path, "p", 0700)
        endif
        let &undodir = target_path
        set undofile
    endif
endfunction

" Plug 'azabiong/vim-highlighter'
function! rookie_plugins#Setup_Highlighter() abort
    nnoremap <silent> <leader>lh :noh<CR>:call ClearHighlight()<CR>
endfunction

" Plug 'junegunn/vim-easy-align'
function! rookie_plugins#Setup_EasyAlign() abort
    nmap ga :EasyAlign<Space>*// {'rm':1}
        \<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
    xmap ga :EasyAlign<Space>*// {'rm':1}
        \<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
endfunction

" Plug 'airblade/vim-rooter'
function! rookie_plugins#Setup_Rooter() abort
    let g:rooter_patterns = [
    \   '.cproject', '.git', '.svn', 'LICENSE',
    \   'Cargo.lock', 'Makefile', '.clang-format']
endfunction

" Plug 'octol/vim-cpp-enhanced-highlight'
function! rookie_plugins#Setup_CppEnhancedHighlight() abort
    let g:cpp_member_variable_highlight = 1
endfunction

" Plug 'github/copilot.vim'
function! rookie_plugins#Setup_Copilot() abort
    let g:copilot_no_tab_map = v:true
    imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
endfunction

" Plug 'brooth/far.vim'
function! rookie_plugins#Setup_Far() abort
    let g:far#source = 'rg'
    let g:far#glob_mode = 'rg'
    let g:far#window_width = 90
    let g:far#preview_window_height = 35
    let g:far#enable_undo = 1
    let g:far#default_file_mask = '**/*.[ch]'
    let g:far#file_mask_favorites = ['**/*.[ch]', '**/*.*', '**/*.md', '**/*.rs']
    let g:far#mode_open = {"regex": 0, "case_sensitive": 0, "word": 0, "substitute": 0}
    " nnoremap <leader><F3> :Fardo<CR>
    " nnoreap <leader><F2> :Far <C-r><C-w>\C <C-r><C-w> **/*.[ch]
    "                       \<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
    " vnoremap <leader><F2> "-y:Far <C-r>-\C <C-r>- **/*.[ch]
    "                       \<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
endfunction