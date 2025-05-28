vim9script

def LiveGrep()
    var user_input = input('Enter your search pattern: ')
    execute("silent! grep " .. user_input .. " .")
    execute("copen")
    execute("redraw!")
enddef

export def Setup()
    if executable('rg')
        set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --hidden grepformat=%f:%l:%c:%m
        nnoremap <leader>gg :silent! grep <C-R><C-W> .<CR>:copen<CR>:redraw!<CR>
        nnoremap <leader>gf :call LiveGrep()<CR>
    endif
enddef
