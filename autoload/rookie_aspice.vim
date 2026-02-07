scriptencoding utf-8

function! s:GetGuidUnderCursor() abort
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
    return l:found_guid
endfunction

function! rookie_aspice#Jump() abort
    if !exists('b:rookie_jump_data')
        return
    endif
    let l:idx = line('.') - 1
    if l:idx < 0 || l:idx >= len(b:rookie_jump_data)
        return
    endif
    let l:item = b:rookie_jump_data[l:idx]
    let l:origin_win = win_getid()

    " Check if we already have a valid shared preview window
    if exists('t:rookie_aspice_preview_winid') && win_id2win(t:rookie_aspice_preview_winid) > 0
        call win_gotoid(t:rookie_aspice_preview_winid)
        execute 'edit ' . fnameescape(l:item.filename)
        call cursor(l:item.lnum, l:item.col)
        normal! zz
        call win_gotoid(l:origin_win)
        return
    endif

    " Attempt to go to the window above
    wincmd k

    " If we fail to move (e.g., only bottom windows exist), create a new split
    " Or if we are still in a quickfix-like buffer
    if &filetype == 'qf'
        " We are still in the qf buffer, meaning wincmd k failed or took us to another qf buffer
        " Try to find a non-qf window
        let l:found = 0
        for l:i in range(1, winnr('$'))
            if getwinvar(l:i, '&filetype') != 'qf'
                execute l:i . 'wincmd w'
                let l:found = 1
                break
            endif
        endfor

        if !l:found
            " No suitable window, create one above
            leftabove new
        endif
    endif

    " Split vertically on the right
    let l:save_splitright = &splitright
    set splitright
    vsplit
    let &splitright = l:save_splitright
    let l:preview_win = win_getid()

    execute 'edit ' . fnameescape(l:item.filename)
    call cursor(l:item.lnum, l:item.col)
    normal! zz

    call win_gotoid(l:origin_win)
    let t:rookie_aspice_preview_winid = l:preview_win
endfunction

function! s:SetupBuffer(title, items) abort
    setlocal buftype=nofile bufhidden=wipe noswapfile
    setlocal filetype=qf
    let w:quickfix_title = a:title

    let l:lines = []
    let l:jump_data = []

    for l:item in a:items
        let l:fname = ''
        if has_key(l:item, 'display_name')
            let l:fname = l:item.display_name
        elseif has_key(l:item, 'filename')
             let l:fname = fnamemodify(l:item.filename, ':t')
        endif

        if len(l:fname) > 16
            let l:fname = strpart(l:fname, 0, 16)
        endif

        call add(l:lines, printf('%-16s|%d col %d| %s', l:fname, l:item.lnum, l:item.col, l:item.text))
        call add(l:jump_data, l:item)
    endfor

    call setline(1, l:lines)
    let b:rookie_jump_data = l:jump_data

    nnoremap <buffer> <CR> :call rookie_aspice#Jump()<CR>

    " Trigger syntax highlighting for qf
    setlocal syntax=qf
endfunction

function! rookie_aspice#ShowTraceability() abort
    let l:guid = s:GetGuidUnderCursor()
    if empty(l:guid)
        echoerr 'No GUID found under cursor.'
        return
    endif

    if !executable('rg')
        echoerr 'rg (ripgrep) is not installed or not in PATH.'
        return
    endif

    let l:cmd = 'rg --vimgrep --no-heading --smart-case --hidden -F "' . l:guid . '" .'
    let l:output = system(l:cmd)

    " Even if output is empty, we might want to show empty lists?
    " User said "after the search done, i want to show..."
    " If not found, maybe just message.
    if empty(l:output)
        echom 'GUID not found in other files.'
        return
    endif

    let l:req_items = []
    let l:sat_items = []
    let l:imp_items = []

    let l:lines = split(l:output, "\n")
    for l:line in l:lines
        " rg --vimgrep format: file:line:col:text
        let l:parts = matchlist(l:line, '^\(.\+\):\(\d\+\):\(\d\+\):\(.*\)$')
        if !empty(l:parts)
            let l:file = l:parts[1]
            let l:lnum = str2nr(l:parts[2])
            let l:col = str2nr(l:parts[3])
            let l:text = l:parts[4]

            let l:item = {
                \ 'filename': l:file,
                \ 'lnum': l:lnum,
                \ 'col': l:col,
                \ 'text': l:text
                \ }

            if l:file =~ 'sys02'
                let l:item.display_name = 'sys02'
                call add(l:req_items, l:item)
            elseif l:file =~ 'swe01'
                let l:item.display_name = 'swe01'
                call add(l:sat_items, l:item)
            elseif l:text =~ '^\s*\/\/'
                call add(l:imp_items, l:item)
            endif
        endif
    endfor

    " Create Layout
    " 1. Create bottom window (Requirement)
    botright 10new
    let l:req_win = win_getid()
    call s:SetupBuffer('Requirement', l:req_items)

    " 2. Split vertically for SatisfiedBy
    vnew
    let l:sat_win = win_getid()
    call s:SetupBuffer('SatisfiedBy', l:sat_items)

    " 3. Split vertically for Implementation
    vnew
    let l:imp_win = win_getid()
    call s:SetupBuffer('Implementation', l:imp_items)

    " Resize windows
    let l:total_width = &columns
    let l:req_width = float2nr(l:total_width * 0.24)
    let l:sat_width = float2nr(l:total_width * 0.38)

    call win_gotoid(l:req_win)
    execute 'vertical resize ' . l:req_width

    call win_gotoid(l:sat_win)
    execute 'vertical resize ' . l:sat_width

    " Ensure we are at Requirement window initially? Or maybe the first one.
    call win_gotoid(l:req_win)
endfunction

function! rookie_aspice#CloseTraceability() abort
    let l:wins_to_close = []
    let l:titles = ['Requirement', 'SatisfiedBy', 'Implementation']

    " Find all windows with the specific titles
    for l:winnr in range(1, winnr('$'))
        let l:title = getwinvar(l:winnr, 'quickfix_title', '')
        if index(l:titles, l:title) >= 0
            let l:winid = win_getid(l:winnr)
            call add(l:wins_to_close, l:winid)
        endif
    endfor

    " Check for shared preview window
    if exists('t:rookie_aspice_preview_winid') && win_id2win(t:rookie_aspice_preview_winid) > 0
        if index(l:wins_to_close, t:rookie_aspice_preview_winid) == -1
            call add(l:wins_to_close, t:rookie_aspice_preview_winid)
        endif
        unlet t:rookie_aspice_preview_winid
    endif

    " Close the windows
    for l:winid in l:wins_to_close
        if win_id2win(l:winid) > 0
            execute win_id2win(l:winid) . 'close'
        endif
    endfor
endfunction
