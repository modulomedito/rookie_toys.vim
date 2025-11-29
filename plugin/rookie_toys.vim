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
command! -nargs=0 -bar RookieRetab call rookie_retab#Retab()
command! -nargs=0 -bar RookieToggleHeaderSource call rookie_tag#ToggleHeaderSource()

command! -nargs=0 -bar RookieGitGraph call rookie_gitgraph#OpenGitGraph(1)
command! -nargs=0 -bar RookieGitGraphLocal call rookie_gitgraph#OpenGitGraph(0)
command! -nargs=0 -bar RookieGitDiff call rookie_gitdiff#Diff()
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

if exists('g:rookie_git_fetch_interval_s')
    call rookie_git#AutoFetch()
endif
call rookie_git#StartAutoFetchWatcher()

if get(g:, 'rookie_rooter_auto_setup', 1)
    call rookie_rooter#Setup()
endif
