scriptencoding utf-8

if exists('g:rookie_toys')
    finish
endif
let g:rookie_toys = 1

" Define user commands that call autoload functions (Vim8 syntax)
command! -nargs=0 -bar RookieMarkdownTitleToAnchor call rookie_markdown#ConvertMarkdownTitleToAnchorLink()
command! -nargs=0 -bar -range RookieMarkdownLinter call rookie_markdown#MarkdownLinter()

command! -nargs=? -bar RookieSlugify echo rookie_markdown#SlugifyString(empty(<q-args>) ? getline('.') : <q-args>)
command! -nargs=0 -bar RookieSlugifyLine call setline('.', rookie_markdown#SlugifyString(getline('.')))
command! -nargs=0 -bar RookieSlugifyYank let _slug = rookie_markdown#SlugifyString(getline('.')) | let @" = _slug | if has('clipboard') | let @+ = _slug | endif | echo _slug

command! -nargs=0 -bar RookieTagUpdate call rookie_tag#UpdateTags()
command! -nargs=0 -bar RookieTagSearch call rookie_tag#SearchTags()
command! -nargs=0 -bar RookieTagSearchGlobal call rookie_tag#SearchGlobalTags()
command! -nargs=0 -bar RookieTagAddFileName call rookie_tag#AddFileNameTags()
command! -nargs=0 -bar RookieTagSearchFileName call rookie_tag#SearchFileNameTags()

command! -nargs=0 -bar RookieClangdGenerate call rookie_clangd#CreateCompileCommandsJson()
command! -nargs=0 -bar RookieRustTestFunctionUnderCursor call rookie_rust#TestFunctionUnderCursor()
command! -nargs=0 -bar RookieRetab call rookie_retab#Retab()
command! -nargs=0 -bar RookieToggleHeaderSource call rookie_tag#ToggleHeaderSource()
command! -nargs=0 -range=-1 -bar RookieHexToAscii call rookie_hex#HexToAscii(<count> != -1)
command! -nargs=0 -range=% -bar RookieHexChecksum call rookie_hex#UpdateIntelHexChecksum()

command! -nargs=0 -bar RookieNERDTreeCopy call rookie_nerdtree#CopyNode()
command! -nargs=0 -bar RookieNERDTreePaste call rookie_nerdtree#PasteNode()

command! -nargs=0 -bar RookieGitGraph call rookie_gitgraph#OpenGitGraph(1)
command! -nargs=0 -bar RookieGitGraphLocal call rookie_gitgraph#OpenGitGraph(0)
command! -nargs=0 -bar RookieGitDiff call rookie_gitdiff#Diff()
command! -nargs=0 -bar RookieGitDiffJumpToChange call rookie_gitdiff#JumpToChange()
command! -nargs=? -bar RookieGitOpenCommitDiff call rookie_git#OpenCommitDiff(<f-args>)
command! -nargs=0 -bar RookieGitDiffFileNext call rookie_git#DiffFileNavigate(1)
command! -nargs=0 -bar RookieGitDiffFilePrevious call rookie_git#DiffFileNavigate(-1)
command! -nargs=0 -bar RookieGitAutoFetch call rookie_git#AutoFetch()

command! -nargs=0 -bar RookieProjectList call rookie_project#ProjectList()
command! -nargs=0 -bar RookieProjectAdd call rookie_project#ProjectAdd()
command! -nargs=0 -bar RookieProjectRemove call rookie_project#ProjectRemove()
command! -nargs=0 -bar RookieProjectRename call rookie_project#ProjectRename()

command! -nargs=0 -bar RookieRooterSetup call rookie_rooter#Setup()
command! -nargs=0 -bar RookieRooterDisable call rookie_rooter#Disable()
command! -nargs=0 -bar RookieRooterEnable let g:rookie_rooter_enable = 1 | call rookie_rooter#Setup()
command! -nargs=0 -bar RookieRooterToggle let g:rookie_rooter_enable = get(g:, 'rookie_rooter_enable', 1) ? 0 : 1 | if g:rookie_rooter_enable | call rookie_rooter#Setup() | else | call rookie_rooter#Disable() | endif
command! -nargs=0 -bar RookieRooterHere call rookie_rooter#RootHere()

command! -nargs=0 -bar RookieGuidGenerate call rookie_guid#Insert()
command! -nargs=0 -bar RookieGuidSearch call rookie_guid#Search()
command! -nargs=0 -bar RookieGuidList call rookie_guid#List()

command! -nargs=0 -bar RookieAspiceShowTraceability call rookie_aspice#ShowTraceability()
command! -nargs=0 -bar RookieAspiceCloseTraceability call rookie_aspice#CloseTraceability()

command! -nargs=0 -bar RookieRgLiveGrep call rookie_rg#LiveGrep()
command! -nargs=0 -bar RookieRgGlobalGrep call rookie_rg#GlobalGrep()
command! -nargs=0 -range -bar RookieRgVisualGrep call rookie_rg#VisualGrep()
command! -nargs=0 -bar RookieRgClearHighlight call rookie_rg#ClearHighlight()

command! -nargs=+ -complete=file RookieFarReplace call rookie_far#Replace(<f-args>)
command! -nargs=+ -complete=file RookieFarFind call rookie_far#Find(<f-args>)
command! -nargs=0 RookieFarDo call rookie_far#Do()

if exists('g:rookie_git_fetch_interval_s')
    call rookie_git#AutoFetch()
endif
call rookie_git#StartAutoFetchWatcher()

if get(g:, 'rookie_rooter_auto_setup', 1)
    call rookie_rooter#Setup()
endif

if !exists('g:rookie_auto_git_graph_enable')
    let g:rookie_auto_git_graph_enable = 0
endif

" Setup keymaps if enabled
if !exists('g:rookie_toys_setup_keymap_enable')
    let g:rookie_toys_setup_keymap_enable = 0
endif
call rookie_setup#SetupKeymaps()

" Setup options if enabled
if !exists('g:rookie_toys_setup_option_enable')
    let g:rookie_toys_setup_option_enable = 0
endif
call rookie_setup#SetupOptions()

" Setup rg if enabled
if !exists('g:rookie_rg_default_setup')
    let g:rookie_rg_default_setup = 0
endif
call rookie_rg#Setup()

" Setup aspice if enabled
if !exists('g:rookie_aspice_default_setup')
    let g:rookie_aspice_default_setup = 0
endif
call rookie_aspice#Setup()

if !exists('g:rookie_toys_syntax_highlight_enable')
    let g:rookie_toys_syntax_highlight_enable = 1
endif

augroup RookieSyntax
    autocmd!
    autocmd FileType * call rookie_syntax#Setup()
augroup END

augroup RookieAutoGitGraph
    autocmd!
    autocmd FocusGained,BufEnter,BufWinEnter * call rookie_gitgraph#CheckGitAndRun()
    autocmd ShellCmdPost * call rookie_gitgraph#CheckGitAndRun()
    autocmd User FugitiveChanged call rookie_gitgraph#CheckGitAndRun()
    autocmd DirChanged * let g:rookie_last_git_state = rookie_gitgraph#GetGitState()
    autocmd FileType gitcommit autocmd BufUnload <buffer> call timer_start(1000, {-> rookie_gitgraph#CheckGitAndRun()})
augroup END

command! -nargs=0 -bar RookieGitGraphAutoToggle let g:rookie_auto_git_graph_enable = get(g:, 'rookie_auto_git_graph_enable', 0) ? 0 : 1 | echo "Auto Git Graph: " . (g:rookie_auto_git_graph_enable ? "On" : "Off")
