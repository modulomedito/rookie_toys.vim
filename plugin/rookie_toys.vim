if !has('vim9script') ||  v:version < 900
    " Needs Vim version 9.0 and above
    finish
endif
vim9script

g:rookie_toys = 1

import autoload 'rookie_clangd.vim'
import autoload 'rookie_gitgraph.vim'
import autoload 'rookie_markdown.vim'
import autoload 'rookie_templatec.vim'

command! -nargs=0 -bar RookieClangdGenerate rookie_clangd.CreateCompileCommandsJson()
command! -nargs=0 -bar RookieGitGraph rookie_gitgraph.OpenGitGraph(1)
command! -nargs=0 -bar RookieGitGraphLocal rookie_gitgraph.OpenGitGraph(0)
command! -nargs=0 -bar RookieMarkdownTitleToAnchor rookie_markdown.ConvertMarkdownTitleToAnchorLink()
command! -nargs=0 -bar RookieTemplateC100 rookie_templatec.C100()
