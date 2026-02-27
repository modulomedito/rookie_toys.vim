scriptencoding utf-8

" Prevents multiple loading
if exists('g:rookie_toys')
    finish
else
    let g:rookie_toys = 1
endif

" Dependency plugins
Plug 'NLKNguyen/papercolor-theme'       " Colorscheme
Plug 'SirVer/ultisnips'                 " Snippets
Plug 'Xuyuanp/nerdtree-git-plugin'      " Nerdtree git icon
Plug 'airblade/vim-gitgutter'           " Git modified signs
Plug 'andrejlevkovitch/vim-lua-format'  " Lua formatter
Plug 'azabiong/vim-highlighter'         " Highlight words
Plug 'catppuccin/nvim'                  " Colorscheme
Plug 'dhruvasagar/vim-table-mode'       " Table alignment
Plug 'godlygeek/tabular'                " Markdown code syntax Highlighting
Plug 'honza/vim-snippets'               " Snippets
Plug 'hotoo/pangu.vim'                  " Chinese formatter
Plug 'joshdick/onedark.vim'             " Colorscheme
Plug 'junegunn/vim-easy-align'          " Easy align
Plug 'justinmk/vim-dirvish'             " File browser
Plug 'kshenoy/vim-signature'            " Bookmarks
Plug 'mbbill/undotree'                  " Undo history visualizer
Plug 'modulomedito/far.vim'             " Find and replace
Plug 'neoclide/coc.nvim', {'branch': 'release'} " LSP
Plug 'octol/vim-cpp-enhanced-highlight' " C language syntax highlight enhance
Plug 'preservim/nerdtree'               " File browser
Plug 'sainnhe/everforest'               " Colorscheme
Plug 'skywind3000/asyncrun.vim'         " Asynchronously run
Plug 't9md/vim-textmanip'               " Text movement
Plug 'tpope/vim-commentary'             " Comment out
Plug 'tpope/vim-fugitive'               " Git integration
Plug 'tpope/vim-surround'               " Surroud word with char
Plug 'tpope/vim-unimpaired'             " Efficient keymaps
Plug 'vim-airline/vim-airline'          " Vim bottom status line
Plug 'vim-airline/vim-airline-themes'   " Vim bottom status line
Plug 'vim-scripts/DrawIt'               " Draw ASCII art

" rookie_markdown
command! -nargs=0 -bar RookieMarkdownTitleToAnchor call rookie_markdown#ConvertMarkdownTitleToAnchorLink()
command! -nargs=0 -bar -range RookieMarkdownLinter call rookie_markdown#MarkdownLinter()
command! -nargs=? -bar RookieSlugify echo rookie_markdown#SlugifyString(empty(<q-args>) ? getline('.') : <q-args>)
command! -nargs=0 -bar RookieSlugifyLine call setline('.', rookie_markdown#SlugifyString(getline('.')))
command! -nargs=0 -bar RookieSlugifyYank let _slug = rookie_markdown#SlugifyString(getline('.')) | let @" = _slug | if has('clipboard') | let @+ = _slug | endif | echo _slug
" rookie_tag
command! -nargs=0 -bar RookieTagUpdate call rookie_tag#UpdateTags()
command! -nargs=0 -bar RookieTagSearch call rookie_tag#SearchTags()
command! -nargs=0 -bar RookieTagSearchGlobal call rookie_tag#SearchGlobalTags()
command! -nargs=0 -bar RookieTagAddFileName call rookie_tag#AddFileNameTags()
command! -nargs=0 -bar RookieTagSearchFileName call rookie_tag#SearchFileNameTags()
" rookie_clangd
command! -nargs=0 -bar RookieClangdGenerate call rookie_clangd#CreateCompileCommandsJson()
command! -nargs=0 -bar RookieRustTestFunctionUnderCursor call rookie_rust#TestFunctionUnderCursor()
command! -nargs=0 -bar RookieRetab call rookie_retab#Retab()
command! -nargs=0 -bar RookieToggleHeaderSource call rookie_tag#ToggleHeaderSource()
command! -nargs=0 -range=-1 -bar RookieHexToAscii call rookie_hex#HexToAscii(<count> != -1)
command! -nargs=0 -range=% -bar RookieHexChecksum call rookie_hex#UpdateIntelHexChecksum()
" rookie_nerdtree
command! -nargs=0 -bar RookieNERDTreeCopy call rookie_nerdtree#CopyNode()
command! -nargs=0 -bar RookieNERDTreePaste call rookie_nerdtree#PasteNode()
" rookie_gitgraph
command! -nargs=0 -bar RookieGitGraph call rookie_gitgraph#OpenGitGraph(1)
command! -nargs=0 -bar RookieGitGraphLocal call rookie_gitgraph#OpenGitGraph(0)
command! -nargs=0 -bar RookieGitDiff call rookie_gitdiff#Diff()
command! -nargs=0 -bar RookieGitDiffJumpToChange call rookie_gitdiff#JumpToChange()
command! -nargs=? -bar RookieGitOpenCommitDiff call rookie_git#OpenCommitDiff(<f-args>)
command! -nargs=0 -bar RookieGitDiffFileNext call rookie_git#DiffFileNavigate(1)
command! -nargs=0 -bar RookieGitDiffFilePrevious call rookie_git#DiffFileNavigate(-1)
command! -nargs=0 -bar RookieGitAutoFetch call rookie_git#AutoFetch()
" rookie_project
command! -nargs=0 -bar RookieProjectList call rookie_project#ProjectList()
command! -nargs=0 -bar RookieProjectAdd call rookie_project#ProjectAdd()
command! -nargs=0 -bar RookieProjectRemove call rookie_project#ProjectRemove()
command! -nargs=0 -bar RookieProjectRename call rookie_project#ProjectRename()
" rookie_rooter
command! -nargs=0 -bar RookieRooterSetup call rookie_rooter#Setup()
command! -nargs=0 -bar RookieRooterDisable call rookie_rooter#Disable()
command! -nargs=0 -bar RookieRooterEnable let g:rookie_rooter_enable = 1 | call rookie_rooter#Setup()
command! -nargs=0 -bar RookieRooterToggle let g:rookie_rooter_enable = get(g:, 'rookie_rooter_enable', 1) ? 0 : 1 | if g:rookie_rooter_enable | call rookie_rooter#Setup() | else | call rookie_rooter#Disable() | endif
command! -nargs=0 -bar RookieRooterHere call rookie_rooter#RootHere()
" rookie_guid
command! -nargs=0 -bar RookieGuidGenerate call rookie_guid#Insert()
command! -nargs=0 -bar RookieGuidSearch call rookie_guid#Search()
command! -nargs=0 -bar RookieGuidList call rookie_guid#List()
" rookie_aspice
command! -nargs=0 -bar RookieAspiceShowTraceability call rookie_aspice#ShowTraceability()
command! -nargs=0 -bar RookieAspiceCloseTraceability call rookie_aspice#CloseTraceability()
" rookie_rg
command! -nargs=0 -bar RookieRgLiveGrep call rookie_rg#LiveGrep()
command! -nargs=0 -bar RookieRgGlobalGrep call rookie_rg#GlobalGrep()
command! -nargs=0 -range -bar RookieRgVisualGrep call rookie_rg#VisualGrep()
command! -nargs=0 -bar RookieRgClearHighlight call rookie_rg#ClearHighlight()
" rookie_far
command! -nargs=+ -complete=file RookieFarReplace call rookie_far#Replace(<f-args>)
command! -nargs=+ -complete=file RookieFarFind call rookie_far#Find(<f-args>)
command! -nargs=0 RookieFarDo call rookie_far#Do()
command! -nargs=0 RookieFarUndo call rookie_far#Undo()
" rookie_smooth
command! -nargs=0 RookieSmoothScrollHalfPageUp call rookie_smooth#HalfPageUp()
command! -nargs=0 RookieSmoothScrollHalfPageDown call rookie_smooth#HalfPageDown()
command! -nargs=0 RookieSmoothScrollPageUp call rookie_smooth#PageUp()
command! -nargs=0 RookieSmoothScrollPageDown call rookie_smooth#PageDown()
" rookie_c
command! -nargs=0 -range -bar RookieCCommentToSlash <line1>,<line2>call rookie_c#CommentToSlash()

" Setup
call rookie_setup#Setup()