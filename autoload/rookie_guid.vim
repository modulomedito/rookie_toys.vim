scriptencoding utf-8

function! rookie_guid#Generate() abort
    if has('win32') || has('win64')
        let l:cmd = 'powershell -NoProfile -NonInteractive -Command "[guid]::NewGuid().ToString().ToUpper()"'
        let l:guid = trim(system(l:cmd))
    else
        " Fallback for non-Windows
        if executable('uuidgen')
            let l:guid = toupper(trim(system('uuidgen')))
        else
            " Simple random fallback
            let l:guid = ''
            for i in range(8) | let l:guid .= printf('%X', rand() % 16) | endfor
            let l:guid .= '-'
            for i in range(4) | let l:guid .= printf('%X', rand() % 16) | endfor
            let l:guid .= '-'
            for i in range(4) | let l:guid .= printf('%X', rand() % 16) | endfor
            let l:guid .= '-'
            for i in range(4) | let l:guid .= printf('%X', rand() % 16) | endfor
            let l:guid .= '-'
            for i in range(12) | let l:guid .= printf('%X', rand() % 16) | endfor
        endif
    endif
    let l:final_guid = '{' . l:guid . '}'

    let l:save_reg = @z
    let @z = l:final_guid
    normal! "zp
    let @z = l:save_reg

    return l:final_guid
endfunction

function! rookie_guid#Insert() abort
    call rookie_guid#Generate()
endfunction

function! rookie_guid#List() abort
    let l:pattern = '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}'
    " Use rg to search in current directory
    if !executable('rg')
        echoerr 'rg (ripgrep) is not installed or not in PATH.'
        return
    endif

    let l:cmd = 'rg --vimgrep --no-heading --smart-case --hidden "' . l:pattern . '" .'
    let l:output = system(l:cmd)

    if empty(l:output)
        echom 'No GUIDs found.'
        cclose
    else
        cgetexpr l:output
        copen
        redraw!
    endif
endfunction

function! rookie_guid#Search() abort
    let l:line = getline('.')
    let l:col = col('.')
    " Vim regex for GUID: 8 hex - 4 hex - 4 hex - 4 hex - 12 hex
    let l:vim_pattern = '\c[0-9A-Fa-f]\{8}-\([0-9A-Fa-f]\{4}-\)\{3}[0-9A-Fa-f]\{12}'

    let l:start_pos = 0
    let l:found_guid = ''

    while 1
        let l:match_start = match(l:line, l:vim_pattern, l:start_pos)
        if l:match_start == -1
            break
        endif
        let l:match_end = matchend(l:line, l:vim_pattern, l:start_pos)

        " Check if cursor is within this match (1-based col vs 0-based match)
        " If cursor is on the character after the match, it's usually considered 'at the end' of the word,
        " but strictly being 'on' the guid means within [start+1, end].
        " Let's be generous: if it touches the GUID.
        if l:col >= (l:match_start + 1) && l:col <= l:match_end
            let l:found_guid = strpart(l:line, l:match_start, l:match_end - l:match_start)
            break
        endif

        let l:start_pos = l:match_end
    endwhile

    if empty(l:found_guid)
        echoerr 'No GUID found under cursor.'
        return
    endif

    if !executable('rg')
        echoerr 'rg (ripgrep) is not installed or not in PATH.'
        return
    endif

    " Use fixed string search (-F) for the specific GUID
    let l:cmd = 'rg --vimgrep --no-heading --smart-case --hidden -F "' . l:found_guid . '" .'
    let l:output = system(l:cmd)

    if empty(l:output)
        echom 'GUID not found in other files.'
    else
        cgetexpr l:output
        copen
        redraw!
    endif
endfunction
