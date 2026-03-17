scriptencoding utf-8

function! rookie_tabrename#Rename(...) abort
    let name = a:0 >= 1 ? a:1 : input('New tab name: ')
    let t:rookie_tab_name = name
    call rookie_tabrename#Enable()
    redrawtabline
endfunction

function! rookie_tabrename#Enable() abort
    if !exists('g:rookie_tabrename_active')
        set tabline=%!rookie_tabrename#TabLine()
        if has('gui_running')
            set guitablabel=%!rookie_tabrename#GuiTabLabel()
        endif
        let g:rookie_tabrename_active = 1
    endif
endfunction

function! rookie_tabrename#TabLine() abort
    let s = ''
    for i in range(tabpagenr('$'))
        let tab = i + 1
        let winnr = tabpagewinnr(tab)
        let buflist = tabpagebuflist(tab)
        let bufnr = buflist[winnr - 1]
        let bufname = bufname(bufnr)
        let bufmodified = getbufvar(bufnr, '&mod')

        let s .= '%' . tab . 'T'
        let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
        let s .= ' ' . tab . ':'

        let tabname = gettabvar(tab, 'rookie_tab_name', '')
        if !empty(tabname)
             let s .= tabname
        elseif empty(bufname)
             let s .= '[No Name]'
        else
             let s .= fnamemodify(bufname, ':t')
        endif

        if bufmodified
            let s .= ' [+]'
        endif
        let s .= ' '
    endfor

    let s .= '%#TabLineFill#%T'
    return s
endfunction

function! rookie_tabrename#GuiTabLabel() abort
    let tab = v:lnum
    let winnr = tabpagewinnr(tab)
    let buflist = tabpagebuflist(tab)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    let bufmodified = getbufvar(bufnr, '&mod')

    let s = ''
    let tabname = gettabvar(tab, 'rookie_tab_name', '')
    if !empty(tabname)
         let s .= tabname
    elseif empty(bufname)
         let s .= '[No Name]'
    else
         let s .= fnamemodify(bufname, ':t')
    endif

    if bufmodified
        let s .= ' [+]'
    endif
    return s
endfunction
