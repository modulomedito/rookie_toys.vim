scriptencoding utf-8

function! rookie_tabbuf#Enable() abort
    " Enable custom tabline
    call rookie_tabrename#Enable()

    " Setup autocmds
    augroup RookieTabBuf
        autocmd!
        autocmd BufAdd * call rookie_tabbuf#OnBufAdd()
        " We might want BufEnter too, to enforce tab switching?
        " For now, just BufAdd handles new buffers.
    augroup END
endfunction

function! rookie_tabbuf#Disable() abort
    augroup RookieTabBuf
        autocmd!
    augroup END
endfunction

function! rookie_tabbuf#OnBufAdd() abort
    let buf = str2nr(expand('<abuf>'))
    if !buflisted(buf) | return | endif
    if getbufvar(buf, '&buftype') != '' | return | endif

    " Ignore NERDTree buffers
    if bufname(buf) =~ 'NERD_tree_\d\+'
        return
    endif

    " If the buffer is already in the current window, do nothing (prevents duplicates)
    if buf == bufnr('%')
        return
    endif

    " Check if current window is reusable (empty and unmodified)
    " We check current window because plugins like NERDTree switch to the target window before editing
    if bufname('%') == '' && !&modified
        " Current window is effectively empty/new. Reuse it.
        return
    endif

    " Otherwise, open in new tab
    execute 'tab sbuffer ' . buf
endfunction
