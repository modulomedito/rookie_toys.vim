scriptencoding utf-8

function! rookie_rg#LiveGrep() abort
    let user_input = input('Enter your search pattern: ')
    execute 'silent! grep ' . user_input . ' .'
    copen
    redraw!
endfunction

function! rookie_rg#Setup() abort
    if executable('rg')
        set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --hidden
        set grepformat=%f:%l:%c:%m
        nnoremap <leader>gg :silent! grep <C-R><C-W> .<CR>:copen<CR>:redraw!<CR>
        nnoremap <leader>gf :call rookie_rg#LiveGrep()<CR>
    endif
endfunction
