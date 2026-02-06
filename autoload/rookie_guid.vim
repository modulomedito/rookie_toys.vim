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

function! rookie_guid#Search() abort
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
