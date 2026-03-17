scriptencoding utf-8

function! rookie_bufoutline#GetBufferList() abort
    let bufs = filter(range(1, bufnr('$')), 'buflisted(v:val)')
    let qf_list = []

    for b in bufs
        " Skip quickfix buffers and NERDTree buffers
        if getbufvar(b, '&buftype') ==# 'quickfix' || getbufvar(b, '&filetype') ==# 'qf'
            continue
        endif
        if getbufvar(b, '&filetype') ==# 'nerdtree'
            continue
        endif

        let name = bufname(b)
        if empty(name)
            let display_name = "[No Name]"
        else
            let display_name = fnamemodify(name, ':t')
        endif

        " Check if modified
        if getbufvar(b, '&modified')
            let display_name .= " [+]"
        endif

        call add(qf_list, {
            \ 'user_data': b,
            \ 'text': display_name,
            \ 'valid': 1
            \ })
    endfor

    return qf_list
endfunction

function! rookie_bufoutline#Open() abort
    " 1. Find the NERDTree window
    let nerdtree_winnr = -1
    for w in range(1, winnr('$'))
        if getbufvar(winbufnr(w), '&filetype') ==# 'nerdtree'
            let nerdtree_winnr = w
            break
        endif
    endfor

    if nerdtree_winnr == -1
        echomsg "No NERDTree window found."
        return
    endif

    " 2. Collect all listed buffers
    let qf_list = rookie_bufoutline#GetBufferList()
    if empty(qf_list)
        echomsg "No listed buffers."
        return
    endif

    " 4. Prepare NERDTree window
    " Go to NERDTree window
    let original_win = winnr()
    execute nerdtree_winnr . 'wincmd w'

    " Set the location list
    call setloclist(0, qf_list)

    " Open the location list window (lopen)
    " By default, lopen opens a window below the current window.
    lopen 10

    " Now we are in the location list window.

    " Customize display to show only filename (text)
    if has('patch-8.2.0959')
        setlocal quickfixtextfunc=rookie_bufoutline#Format
    else
        " Fallback for older Vim: conceal the leading '|| '
        if has('conceal')
            setlocal conceallevel=2
            setlocal concealcursor=nvic
            " The default format without bufnr is '|| text'
            " Hide the leading '|| '
            syn match qfSeparator /^|| / conceal
        endif
    endif

    nnoremap <buffer> <silent> x :call rookie_bufoutline#DeleteBuffer()<CR>
    nnoremap <buffer> <silent> o :call rookie_bufoutline#OpenBuffer()<CR>
    nnoremap <buffer> <silent> <CR> :call rookie_bufoutline#OpenBuffer()<CR>

    " Set filetype for syntax highlighting (optional)
    " We explicitly set syntax to qf, but we add our match
    setlocal filetype=qf
    if !has('patch-8.2.0959') && has('conceal')
        syn match qfSeparator /^|| / conceal
    endif

    " Return focus to the NERDTree window
    " We are currently in the location list window (opened by lopen)
    " The previous window was NERDTree.
    wincmd p
endfunction

function! rookie_bufoutline#Update() abort
    " Only update if the outline is already open
    " Find NERDTree window first
    let nerdtree_winnr = -1
    for w in range(1, winnr('$'))
        if getbufvar(winbufnr(w), '&filetype') ==# 'nerdtree'
            let nerdtree_winnr = w
            break
        endif
    endfor

    if nerdtree_winnr == -1
        return
    endif

    " Check if loclist window is open for NERDTree window
    " getloclist(nerdtree_winnr, {'winid': 0}).winid
    let loc_info = getloclist(nerdtree_winnr, {'winid': 0})
    let loc_winid = get(loc_info, 'winid', 0)
    if loc_winid == 0
        " Location list window is not open, do nothing
        return
    endif

    " Update the list
    let qf_list = rookie_bufoutline#GetBufferList()
    call setloclist(nerdtree_winnr, qf_list)

    " Find current buffer index to highlight it
    let current_buf = bufnr('%')
    let target_idx = 0
    let i = 1
    for item in qf_list
        if item.user_data == current_buf
            let target_idx = i
            break
        endif
        let i += 1
    endfor

    if target_idx > 0
        " Set the current entry in the location list
        call setloclist(nerdtree_winnr, [], 'a', {'idx': target_idx})

        " Move the cursor in the location list window to the current entry
        if exists('*win_execute')
            call win_execute(loc_winid, 'call cursor(' . target_idx . ', 1)')
            call win_execute(loc_winid, 'normal! zz')
        endif
    endif
endfunction

function! rookie_bufoutline#Format(info) abort
    if a:info.quickfix
        let items = getqflist({'id': a:info.id, 'items': 1}).items
    else
        let items = getloclist(a:info.winid, {'id': a:info.id, 'items': 1}).items
    endif
    let l = []
    for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
        call add(l, items[idx].text)
    endfor
    return l
endfunction

function! rookie_bufoutline#DeleteBuffer() abort
    let line = line('.')
    let list = getloclist(0)
    if empty(list) || line > len(list)
        return
    endif

    let item = list[line - 1]
    " Retrieve bufnr from user_data
    let bufnr = get(item, 'user_data', 0)

    if bufnr == 0
        return
    endif

    " Delete the buffer
    if buflisted(bufnr)
        execute 'bdelete ' . bufnr
    endif

    " Refresh the list
    call rookie_bufoutline#Update()
endfunction

function! rookie_bufoutline#OpenBuffer() abort
    let line = line('.')
    let list = getloclist(0)
    if empty(list) || line > len(list)
        return
    endif

    let item = list[line - 1]
    " Retrieve bufnr from user_data
    let bufnr = get(item, 'user_data', 0)

    if bufnr == 0 || !buflisted(bufnr)
        echomsg "Buffer is not listed."
        return
    endif

    " Try to find a suitable window (not NERDTree, not qf)
    let target_win = -1
    let previous_win = winnr('#')

    " Check previous window first
    if previous_win > 0
        let win_buf = winbufnr(previous_win)
        let win_ft = getbufvar(win_buf, '&filetype')
        if win_ft !=# 'nerdtree' && win_ft !=# 'qf'
            let target_win = previous_win
        endif
    endif

    " If previous window is not suitable, search for any usable window
    if target_win == -1
        for w in range(1, winnr('$'))
            let win_buf = winbufnr(w)
            let win_ft = getbufvar(win_buf, '&filetype')
            if win_ft !=# 'nerdtree' && win_ft !=# 'qf'
                let target_win = w
                break
            endif
        endfor
    endif

    if target_win != -1
        " Switch to target window and open buffer
        execute target_win . 'wincmd w'
        execute 'buffer ' . bufnr
    else
        " No usable window found.
        " Create a new vertical split relative to NERDTree (to the right)

        " Find NERDTree window
        let nerdtree_win = -1
        for w in range(1, winnr('$'))
             if getbufvar(winbufnr(w), '&filetype') ==# 'nerdtree'
                let nerdtree_win = w
                break
             endif
        endfor

        if nerdtree_win != -1
            execute nerdtree_win . 'wincmd w'
            " Split vertically to the right
            execute 'rightbelow vsplit'
            execute 'buffer ' . bufnr
        else
            " Fallback: just split current window (though unlikely if NERDTree is required for this feature)
            execute 'rightbelow vsplit'
            execute 'buffer ' . bufnr
        endif
    endif
endfunction

function! rookie_bufoutline#Prev() abort
    if &filetype ==# 'qf'
        if line('.') > 1
            normal! k
            call rookie_bufoutline#OpenBuffer()
        endif
    else
        let qf_list = rookie_bufoutline#GetBufferList()
        if empty(qf_list)
            return
        endif

        let cur_buf = bufnr('%')
        let idx = -1
        let i = 0
        for item in qf_list
            if item.user_data == cur_buf
                let idx = i
                break
            endif
            let i += 1
        endfor

        if idx > 0
            let prev_buf = qf_list[idx - 1].user_data
            execute 'buffer ' . prev_buf
        endif
    endif
endfunction

function! rookie_bufoutline#Next() abort
    if &filetype ==# 'qf'
        if line('.') < line('$')
            normal! j
            call rookie_bufoutline#OpenBuffer()
        endif
    else
        let qf_list = rookie_bufoutline#GetBufferList()
        if empty(qf_list)
            return
        endif

        let cur_buf = bufnr('%')
        let idx = -1
        let i = 0
        for item in qf_list
            if item.user_data == cur_buf
                let idx = i
                break
            endif
            let i += 1
        endfor

        if idx != -1 && idx < len(qf_list) - 1
            let next_buf = qf_list[idx + 1].user_data
            execute 'buffer ' . next_buf
        endif
    endif
endfunction

function! rookie_bufoutline#SmartDeleteBuffer() abort
    let cur_buf = bufnr('%')
    let qf_list = rookie_bufoutline#GetBufferList()

    if len(qf_list) <= 1
        " If it's the only buffer or no buffers listed, create a new one instead of closing window
        enew
        if buflisted(cur_buf)
            execute 'bdelete ' . cur_buf
        endif
        call rookie_bufoutline#Update()
        return
    endif

    " Find current buffer index
    let idx = -1
    let i = 0
    for item in qf_list
        if item.user_data == cur_buf
            let idx = i
            break
        endif
        let i += 1
    endfor

    " Determine which buffer to switch to
    let target_buf = -1
    if idx != -1
        if idx < len(qf_list) - 1
            " Switch to next buffer
            let target_buf = qf_list[idx + 1].user_data
        elseif idx > 0
            " Switch to previous buffer
            let target_buf = qf_list[idx - 1].user_data
        endif
    endif

    " Switch to target buffer if found
    if target_buf != -1
        execute 'buffer ' . target_buf
    endif

    " Delete the original buffer
    if buflisted(cur_buf)
        execute 'bdelete ' . cur_buf
    endif

    call rookie_bufoutline#Update()
endfunction

function! rookie_bufoutline#EnableAutoUpdate() abort
    augroup RookieBufOutline
        autocmd!
        autocmd BufAdd,BufDelete,BufWipeout,BufEnter * call rookie_bufoutline#Update()
    augroup END
endfunction

function! rookie_bufoutline#Setup() abort
    nnoremap <silent> <C-Home> :call rookie_bufoutline#Prev()<CR>
    nnoremap <silent> <C-End> :call rookie_bufoutline#Next()<CR>
    cabbrev bd call rookie_bufoutline#SmartDeleteBuffer()
endfunction

function! rookie_bufoutline#AutoOpen() abort
    " Add delay to ensure NERDTree content is loaded
    call timer_start(200, {-> rookie_bufoutline#Open()})
endfunction

function! rookie_bufoutline#AutoClose() abort
    " Get location list window ID for the current window (NERDTree)
    let l:loc_info = getloclist(0, {'winid': 0})
    let l:loc_winid = get(l:loc_info, 'winid', 0)

    if l:loc_winid != 0
        let l:win_nr = win_id2win(l:loc_winid)
        if l:win_nr > 0
            execute l:win_nr . 'wincmd q'
        endif
    endif
endfunction

" Enable it by default or call it from plugin file
call rookie_bufoutline#EnableAutoUpdate()
