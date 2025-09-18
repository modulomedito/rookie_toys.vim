if !has('vim9script') ||  v:version < 900
    " Needs Vim version 9.0 and above
    finish
endif
vim9script

g:rookie_toys = 1

import autoload 'rookie_clangd.vim'
import autoload 'rookie_gitdiff.vim'
import autoload 'rookie_gitgraph.vim'
import autoload 'rookie_markdown.vim'
import autoload 'rookie_retab.vim'
import autoload 'rookie_setup.vim'
import autoload 'rookie_tag.vim'

command! -nargs=0 -bar RookieClangdGenerate rookie_clangd.CreateCompileCommandsJson()
command! -nargs=0 -bar RookieGitGraph rookie_gitgraph.OpenGitGraph(1)
command! -nargs=0 -bar RookieGitGraphLocal rookie_gitgraph.OpenGitGraph(0)
command! -nargs=0 -bar RookieMarkdownTitleToAnchor rookie_markdown.ConvertMarkdownTitleToAnchorLink()
command! -nargs=0 -bar RookieMarkdownLinter rookie_markdown.MarkdownLinter()
command! -nargs=0 -bar RookieRetab rookie_retab.Retab()
command! -nargs=0 -bar RookieGitDiff rookie_gitdiff.Diff()
command! -nargs=0 -bar RookieTagUpdate rookie_tag.UpdateTags()
command! -nargs=0 -bar RookieTagSearch rookie_tag.SearchTags()
command! -nargs=0 -bar RookieTagSearchGlobal rookie_tag.SearchGlobalTags()
command! -nargs=0 -bar RookieTagAddFileName rookie_tag.AddFileNameTags()
command! -nargs=0 -bar RookieTagSearchFileName rookie_tag.SearchFileNameTags()
command! -nargs=0 -bar RookieToggleHeaderSource rookie_tag.ToggleHeaderSource()