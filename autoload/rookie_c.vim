scriptencoding utf-8

function! rookie_c#CommentToSlash() abort range
    let l:save_cursor = getcurpos()
    try
        execute a:firstline . ',' . a:lastline . 's/\/\*\+\s\+\(.*\)\*\/\/\/ \1/g'
    catch /^Vim\%((\a\+)\)\=:E486/
        " Ignore pattern not found
    endtry
    call setpos('.', l:save_cursor)
endfunction
