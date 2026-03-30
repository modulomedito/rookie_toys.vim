function! s:GetPath(...) abort
    if a:0 > 0 && !empty(a:1)
        return a:1
    endif
    if &filetype ==# 'nerdtree' && exists('g:NERDTreeFileNode')
        let l:node = g:NERDTreeFileNode.GetSelected()
        if !empty(l:node)
            return l:node.path.str()
        endif
    endif
    return expand('%:p')
endfunction

function! rookie_7zip#Zip(...) abort
    let l:path = a:0 > 0 ? s:GetPath(a:1) : s:GetPath()
    if empty(l:path)
        echoerr 'No path provided'
        return
    endif
    let l:path = fnamemodify(l:path, ':p')
    " remove trailing slash
    let l:path = substitute(l:path, '[/\\]$', '', '')

    let l:dir = fnamemodify(l:path, ':h')
    let l:name = fnamemodify(l:path, ':t')
    let l:zip_file = l:dir . '/' . l:name . '.zip'

    let l:cmd = '7z a "' . l:zip_file . '" "' . l:path . '"'
    if has('win32') || has('win64')
        execute 'silent !start cmd /c "' . l:cmd . '"'
    else
        execute 'silent !' . l:cmd . ' &'
    endif
    echo 'Zipping ' . l:path . ' to ' . l:zip_file . '...'
endfunction

function! rookie_7zip#Unzip(...) abort
    let l:path = a:0 > 0 ? s:GetPath(a:1) : s:GetPath()
    if empty(l:path)
        echoerr 'No path provided'
        return
    endif
    let l:path = fnamemodify(l:path, ':p')

    let l:dir = fnamemodify(l:path, ':h')
    let l:name_no_ext = fnamemodify(l:path, ':t:r')
    let l:out_dir = l:dir . '/' . l:name_no_ext

    let l:cmd = '7z x "' . l:path . '" -o"' . l:out_dir . '"'
    if has('win32') || has('win64')
        execute 'silent !start cmd /c "' . l:cmd . '"'
    else
        execute 'silent !' . l:cmd . ' &'
    endif
    echo 'Unzipping ' . l:path . ' to ' . l:out_dir . '...'
endfunction