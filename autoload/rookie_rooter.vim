scriptencoding utf-8

" rookie_rooter global options
" g:rookie_rooter_enable           (default: 0)
"     Enable/disable auto-root on buffer enter.
" g:rookie_rooter_scope            (default: 'cd')
"     Scope of CWD change: 'cd' (global), 'tcd' (tab-local), or 'lcd' (window-local).
" g:rookie_rooter_patterns         (default: ['.git','compile_commands.json','Cargo.toml','Makefile','.root'])
"     Upward search markers used to detect the project root.
" g:rookie_rooter_exclude_filetypes (default: ['git','help','qf','quickfix','nerdtree'])
"     Filetypes excluded from auto-root behavior.
" g:rookie_rooter_lock_seconds     (default: 2)
"     Cooldown to avoid auto-root overriding CWD right after rookie_project opens a project.
" g:rookie_rooter_auto_setup       (default: 1)
"     Automatically call RookieRooterSetup on plugin load.

function! s:NormalizePath(p) abort
    let p = trim(a:p)
    let p = substitute(p, '\r\|\n', '', 'g')
    let p = fnamemodify(p, ':p')
    return p
endfunction

function! s:FindRoot(start) abort
    let start = s:NormalizePath(a:start)
    let patterns = get(g:, 'rookie_rooter_patterns', ['.git', 'compile_commands.json', 'Cargo.toml', 'Makefile', '.root'])
    for pat in patterns
        let d = finddir(pat, start . ';')
        if !empty(d)
            return {'root': fnamemodify(d, ':h'), 'marker': pat}
        endif
        let f = findfile(pat, start . ';')
        if !empty(f)
            return {'root': fnamemodify(f, ':h'), 'marker': pat}
        endif
    endfor
    return {'root': '', 'marker': ''}
endfunction

function! rookie_rooter#Lock(seconds) abort
    let sec = max([1, a:seconds])
    let g:rookie_rooter_lock_expire = localtime() + sec
endfunction

function! s:LockActive() abort
    return localtime() < get(g:, 'rookie_rooter_lock_expire', 0)
endfunction

function! rookie_rooter#AutoRoot() abort
    if !get(g:, 'rookie_rooter_enable', 0)
        return
    endif
    if s:LockActive()
        return
    endif
    if &buftype !=# ''
        return
    endif
    let ft_ex = get(g:, 'rookie_rooter_exclude_filetypes', ['git', 'help', 'qf', 'quickfix', 'nerdtree'])
    if index(ft_ex, &filetype) >= 0
        return
    endif
    let bufpath = expand('%:p')
    if bufpath ==# ''
        return
    endif
    let found = s:FindRoot(fnamemodify(bufpath, ':h'))
    let root = s:NormalizePath(get(found, 'root', ''))
    let marker = get(found, 'marker', '')
    if root ==# ''
        return
    endif
    if getcwd() ==# root
        return
    endif
    let scope = get(g:, 'rookie_rooter_scope', 'cd')
    if scope !=# 'cd' && scope !=# 'tcd' && scope !=# 'lcd'
        let scope = 'cd'
    endif
    execute scope . ' ' . fnameescape(root)
    if get(g:, 'rookie_rooter_echo_changed', 1)
        echomsg 'RookieRooter: CWD changed to ' . root . (marker !=# '' ? ' (marker: ' . marker . ')' : '')
    endif
endfunction

function! rookie_rooter#Disable() abort
    augroup RookieRooter
        autocmd!
    augroup END
endfunction

function! rookie_rooter#Setup() abort
    call rookie_rooter#Disable()
    if get(g:, 'rookie_rooter_enable', 0)
        augroup RookieRooter
            autocmd!
            autocmd BufEnter * call rookie_rooter#AutoRoot()
        augroup END
    endif
endfunction

function! rookie_rooter#RootHere() abort
    let bufpath = expand('%:p')
    " Fallback for unsaved/new buffers: use current working directory
    if bufpath ==# ''
        let bufpath = getcwd()
    endif
    let found = s:FindRoot(fnamemodify(bufpath, ':h'))
    let root = s:NormalizePath(get(found, 'root', ''))
    let marker = get(found, 'marker', '')
    if root ==# ''
        return
    endif
    let scope = get(g:, 'rookie_rooter_scope', 'cd')
    if scope !=# 'cd' && scope !=# 'tcd' && scope !=# 'lcd'
        let scope = 'cd'
    endif
    execute scope . ' ' . fnameescape(root)
    if get(g:, 'rookie_rooter_echo_changed', 1)
        echomsg 'RookieRooter: CWD changed to ' . root . (marker !=# '' ? ' (marker: ' . marker . ')' : '')
    endif
    " Sync NERDTree root to the new CWD when NERDTree is open
    if exists(':NERDTreeCWD')
        let has_tree = 0
        for binfo in getbufinfo({'bufloaded': 1})
            if getbufvar(binfo.bufnr, '&filetype') ==# 'nerdtree'
                let has_tree = 1
                break
            endif
        endfor
        if has_tree
            execute 'NERDTreeCWD'
        endif
    endif
endfunction
