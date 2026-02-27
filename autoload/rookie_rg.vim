scriptencoding utf-8

"===============================================================================
" Helpers
"===============================================================================
function! s:GetVisualSelection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! s:ExecuteGrep(args)
    let l:grep_cmd = 'silent! grep ' . a:args . ' .'
    execute l:grep_cmd
    if len(getqflist()) > 0
        copen
        wincmd p
        execute 'redraw!'
    else
        cclose
        redraw
        echo "No matches found."
    endif
endfunction

"===============================================================================
" Public Functions
"===============================================================================
function! rookie_rg#LiveGrep() abort
    let user_input = input('Grep Pattern: ')
    if user_input == ''
        return
    endif
    call s:ExecuteGrep(user_input)
    let @/ = '\V' . user_input
endfunction

function! rookie_rg#GlobalGrep() abort
    let word = expand('<cword>')
    if word == ''
        return
    endif

    let l:curr_buf = bufnr('%')
    let l:curr_lnum = line('.')

    call s:ExecuteGrep('-w ' . shellescape(word))
    let @/ = '\V' . word

    let l:qflist = getqflist()
    if empty(l:qflist)
        return
    endif

    let l:idx = -1
    for i in range(len(l:qflist))
        if l:qflist[i].bufnr == l:curr_buf && l:qflist[i].lnum == l:curr_lnum
            let l:idx = i
            break
        endif
    endfor

    if l:idx > 0
        let l:item = remove(l:qflist, l:idx)
        call insert(l:qflist, l:item, 0)
        call setqflist(l:qflist)
    endif
endfunction

function! rookie_rg#VisualGrep() abort
    let selection = s:GetVisualSelection()
    if selection == ''
        return
    endif
    call s:ExecuteGrep('-F ' . shellescape(selection))
    let @/ = '\V' . selection
endfunction

function! rookie_rg#ClearHighlight() abort
    if exists('g:loaded_vim_highlighter')
        execute 'Hi clear'
    endif
endfunction

function! rookie_rg#Setup() abort
    if executable('rg')
        set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --hidden
        set grepformat=%f:%l:%c:%m

        let mapleader = ''
        nnoremap <leader>gg :call rookie_rg#GlobalGrep()<CR>n
        vnoremap <leader>gg :<C-u>call rookie_rg#VisualGrep()<CR>n
        nnoremap <leader>gf :call rookie_rg#LiveGrep()<CR>
    endif
endfunction
