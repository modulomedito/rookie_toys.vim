scriptencoding utf-8

function! rookie_guid#New() abort
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
    return '{' . l:guid . '}'
endfunction

function! rookie_guid#Generate() abort
    let l:final_guid = rookie_guid#New()

    let l:save_reg = @z
    let @z = l:final_guid
    normal! "zp
    let @z = l:save_reg

    return l:final_guid
endfunction

function! rookie_guid#Insert() abort
    call rookie_guid#Generate()
endfunction

function! rookie_guid#QuickfixTextFunc(info) abort
    if a:info.quickfix
        let l:qflist = getqflist({'id': a:info.id, 'items': 1}).items
    else
        let l:qflist = getloclist(a:info.winid, {'id': a:info.id, 'items': 1}).items
    endif

    let l:lines = []
    for l:idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
        let l:item = l:qflist[l:idx]
        if l:item.valid
            let l:fname = ''
            if l:item.bufnr > 0
                 let l:fname = fnamemodify(bufname(l:item.bufnr), ':t')
            elseif has_key(l:item, 'filename')
                 let l:fname = fnamemodify(l:item.filename, ':t')
            endif

            if len(l:fname) > 32
                let l:fname = strpart(l:fname, 0, 32)
            endif

            call add(l:lines, printf('%-32s|%d col %d| %s', l:fname, l:item.lnum, l:item.col, l:item.text))
        else
            call add(l:lines, l:item.text)
        endif
    endfor
    return l:lines
endfunction

function! rookie_guid#ParseAndSetQf(cmd, title) abort
    let l:output = system(a:cmd)

    if empty(l:output)
        return 0
    endif

    let l:items = []
    let l:lines = split(l:output, "\n")

    " Check if bufadd exists (Vim 8.1+)
    let l:has_bufadd = exists('*bufadd')

    for l:line in l:lines
        " rg --vimgrep format: file:line:col:text
        let l:parts = matchlist(l:line, '^\(.\+\):\(\d\+\):\(\d\+\):\(.*\)$')
        if !empty(l:parts)
            let l:file = l:parts[1]
            let l:lnum = str2nr(l:parts[2])
            let l:col = str2nr(l:parts[3])
            let l:text = l:parts[4]

            let l:bufnr = 0
            if l:has_bufadd
                let l:bufnr = bufadd(l:file)
            endif

            call add(l:items, {
                \ 'filename': l:file,
                \ 'lnum': l:lnum,
                \ 'col': l:col,
                \ 'text': l:text,
                \ 'bufnr': l:bufnr
                \ })
        endif
    endfor

    if empty(l:items)
        return 0
    endif

    " Use quickfixtextfunc if available (Vim 8.2.0869+)
    let l:opts = {'title': a:title, 'items': l:items}
    if has('patch-8.2.0869') || has('nvim')
         let l:opts.quickfixtextfunc = 'rookie_guid#QuickfixTextFunc'
    endif

    call setqflist([], 'r', l:opts)
    copen
    redraw!
    return 1
endfunction

function! rookie_guid#List() abort
    let l:pattern = '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}'
    if !executable('rg')
        echoerr 'rg (ripgrep) is not installed or not in PATH.'
        return
    endif

    let l:cmd = 'rg --vimgrep --no-heading --smart-case --hidden "' . l:pattern . '" .'
    if !rookie_guid#ParseAndSetQf(l:cmd, 'GUID List')
        echom 'No GUIDs found.'
        cclose
    endif
endfunction

function! rookie_guid#Search() abort
    let l:line = getline('.')
    let l:col = col('.')
    let l:vim_pattern = '\c[0-9A-Fa-f]\{8}-\([0-9A-Fa-f]\{4}-\)\{3}[0-9A-Fa-f]\{12}'

    let l:start_pos = 0
    let l:found_guid = ''

    while 1
        let l:match_start = match(l:line, l:vim_pattern, l:start_pos)
        if l:match_start == -1
            break
        endif
        let l:match_end = matchend(l:line, l:vim_pattern, l:start_pos)

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

    let l:cmd = 'rg --vimgrep --no-heading --smart-case --hidden -F "' . l:found_guid . '" .'
    if !rookie_guid#ParseAndSetQf(l:cmd, 'GUID Search: ' . l:found_guid)
        echom 'GUID not found in other files.'
    endif
endfunction
