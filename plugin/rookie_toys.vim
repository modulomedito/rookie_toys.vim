if !has('vim9script') ||  v:version < 900
    " Needs Vim version 9.0 and above
    finish
endif
vim9script

g:rookie_toys = 1

import autoload 'rookie_clangd.vim'
import autoload 'rookie_gitgraph.vim'

command! -nargs=0 RookieClangdGenerate rookie_clangd.CreateCompileCommandsJson()
command! -nargs=0 RookieGitGraph rookie_gitgraph.OpenGitGraph(1)
command! -nargs=0 RookieGitGraphLocal rookie_gitgraph.OpenGitGraph(0)
