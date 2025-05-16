if !has('vim9script') ||  v:version < 900
    " Needs Vim version 9.0 and above
    finish
endif
vim9script

import autoload 'rookie_clangd.vim'

command! -nargs=0 RkMc rookie_clangd.CreateCompileCommandsJson()
