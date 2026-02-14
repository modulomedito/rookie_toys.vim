scriptencoding utf-8

let s:last_pattern = ''
let s:last_replace = ''
let s:last_flags = ''

" Find only
function! rookie_far#Find(...) abort
    let l:pattern = get(a:000, 0, '')
    let l:file_mask = get(a:000, 1, '')
    call s:RunSearch(l:pattern, l:file_mask)
endfunction

" Find and prepare for Replace
function! rookie_far#Replace(...) abort
    let l:pattern = get(a:000, 0, '')
    let l:replace_with = get(a:000, 1, '')
    let l:file_mask = get(a:000, 2, '')

    let s:last_pattern = l:pattern
    let s:last_replace = l:replace_with
    let s:last_flags = 'g'

    call s:RunSearch(l:pattern, l:file_mask)

    if len(getqflist()) > 0
        echo "RookieFar: Found matches. Run :RookieFarDo to execute replacement."
    else
        echo "RookieFar: No matches found."
    endif
endfunction

" Execute the replacement
function! rookie_far#Do() abort
    if empty(s:last_pattern)
        echoerr "RookieFar: No search pattern defined."
        return
    endif

    let l:pattern = s:last_pattern
    let l:replace = s:last_replace
    let l:flags = s:last_flags . 'e' " 'e' flag to suppress error if pattern not found in a file (though rg found it, maybe modified?)

    " Escape delimiter / for substitute command
    let l:safe_pattern = substitute(l:pattern, '/', '\\/', 'g')
    let l:safe_replace = substitute(l:replace, '/', '\\/', 'g')

    " Use cfdo to execute substitution on each file in the quickfix list
    " %s/pat/rep/ge | update
    let l:cmd = 'cfdo %s/' . l:safe_pattern . '/' . l:safe_replace . '/' . l:flags . ' | update'

    try
        execute l:cmd
        echo "RookieFar: Replacement complete."
    catch
        echoerr "RookieFar: Replacement failed: " . v:exception
    endtry
endfunction

function! s:RunSearch(pattern, file_mask)
    let l:pattern = a:pattern
    let l:rg_opts = '--vimgrep --no-heading --hidden'

    " Handle Vim case sensitivity flags \C and \c
    " rg uses -s (sensitive) and -i (ignore).
    " Default to smart-case if neither is present.
    if l:pattern =~# '\\C'
        let l:rg_opts .= ' -s'
        let l:pattern = substitute(l:pattern, '\\C', '', 'g')
    elseif l:pattern =~# '\\c'
        let l:rg_opts .= ' -i'
        let l:pattern = substitute(l:pattern, '\\c', '', 'g')
    else
        let l:rg_opts .= ' --smart-case'
    endif

    " Construct command
    let l:cmd = 'rg ' . l:rg_opts . ' -e ' . shellescape(l:pattern)

    if !empty(a:file_mask)
        " If file_mask contains wildcards, pass it with -g
        if a:file_mask =~# '[*?\[]'
             let l:cmd .= ' -g ' . shellescape(a:file_mask)
        else
             let l:cmd .= ' ' . shellescape(a:file_mask)
        endif
    endif

    " Run rg
    let l:grep_output = system(l:cmd)

    " Populate quickfix
    cgetexpr l:grep_output

    if len(getqflist()) > 0
        copen
    endif
endfunction
