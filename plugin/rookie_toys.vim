scriptencoding utf-8

if exists('g:rookie_toys')
    finish
endif
let g:rookie_toys = 1

" Define user commands that call autoload functions (Vim8 syntax)
command! -nargs=0 -bar RookieClangdGenerate call rookie_clangd#CreateCompileCommandsJson()
command! -nargs=0 -bar RookieGitGraph call rookie_gitgraph#OpenGitGraph(1)
command! -nargs=0 -bar RookieGitGraphLocal call rookie_gitgraph#OpenGitGraph(0)
command! -nargs=0 -bar RookieMarkdownTitleToAnchor call rookie_markdown#ConvertMarkdownTitleToAnchorLink()
command! -nargs=0 -bar RookieMarkdownLinter call rookie_markdown#MarkdownLinter()
command! -nargs=0 -bar RookieRetab call rookie_retab#Retab()
command! -nargs=0 -bar RookieGitDiff call rookie_gitdiff#Diff()
command! -nargs=0 -bar RookieTagUpdate call rookie_tag#UpdateTags()
command! -nargs=0 -bar RookieTagSearch call rookie_tag#SearchTags()
command! -nargs=0 -bar RookieTagSearchGlobal call rookie_tag#SearchGlobalTags()
command! -nargs=0 -bar RookieTagAddFileName call rookie_tag#AddFileNameTags()
command! -nargs=0 -bar RookieTagSearchFileName call rookie_tag#SearchFileNameTags()
command! -nargs=0 -bar RookieToggleHeaderSource call rookie_tag#ToggleHeaderSource()