scriptencoding utf-8

let s:last_pattern = ''
let s:last_replace = ''
let s:last_flags = ''

" Find only
function! rookie_far#Find(...) abort
    let l:pattern = get(a:000, 0, '')
    let l:file_mask = get(a:000, 1, '')
    call s:RunSearch(l:pattern, l:file_mask)
endfunction

" Find and prepare for Replace
function! rookie_far#Replace(...) abort
    let l:pattern = get(a:000, 0, '')
    let l:replace_with = get(a:000, 1, '')
    let l:file_mask = get(a:000, 2, '')

    let s:last_pattern = l:pattern
    let s:last_replace = l:replace_with
    let s:last_flags = 'g' 
    
    call s:RunSearch(l:pattern, l:file_mask)
    
    if len(getqflist()) > 0
        echo "RookieFar: Found matches. Run :RookieFarDo to execute replacement."
    endif
endfunction

" Execute the replacement
function! rookie_far#Do() abort
    if empty(s:last_pattern)
        echoerr "RookieFar: No search pattern defined."
        return
    endif
    
    let l:pattern = s:last_pattern
    let l:replace = s:last_replace
    let l:flags = s:last_flags . 'e' 
    
    let l:safe_pattern = substitute(l:pattern, '/', '\\/', 'g')
    let l:safe_replace = substitute(l:replace, '/', '\\/', 'g')
    
    let l:cmd = 'cfdo %s/' . l:safe_pattern . '/' . l:safe_replace . '/' . l:flags . ' | update'
    
    try
        execute l:cmd
        echo "RookieFar: Replacement complete."
    catch
        echoerr "RookieFar: Replacement failed: " . v:exception
    endtry
endfunction

function! s:RunSearch(pattern, file_mask)
    let l:pattern = a:pattern
    let l:rg_opts = '--vimgrep --no-heading --hidden'
    
    if l:pattern =~# '\\C'
        let l:rg_opts .= ' -s'
        let l:pattern = substitute(l:pattern, '\\C', '', 'g')
    elseif l:pattern =~# '\\c'
        let l:rg_opts .= ' -i'
        let l:pattern = substitute(l:pattern, '\\c', '', 'g')
    else
        let l:rg_opts .= ' --smart-case'
    endif
    
    let l:cmd = 'rg ' . l:rg_opts . ' -e ' . shellescape(l:pattern)
    
    if !empty(a:file_mask)
        if a:file_mask =~# '[*?\[]'
             let l:cmd .= ' -g ' . shellescape(a:file_mask)
        else
             let l:cmd .= ' ' . shellescape(a:file_mask)
        endif
    endif
    
    let l:grep_output = system(l:cmd)
    
    let l:old_efm = &efm
    set efm=%f:%l:%c:%m
    try
        cgetexpr l:grep_output
    finally
        let &efm = l:old_efm
    endtry
    
    let l:qf_list = getqflist()
    if len(l:qf_list) > 0
        let l:ctx = s:ComputeFileMapping(l:qf_list)
        call setqflist([], 'r', {'context': l:ctx, 'quickfixtextfunc': 'rookie_far#QuickfixTextFunc'})
        copen
    else
        cclose
        echo "RookieFar: No matches found."
    endif
endfunction

function! s:ComputeFileMapping(items)
    let l:path_to_name = {}
    let l:name_to_paths = {}
    
    " Collect all paths
    for l:item in a:items
        if !has_key(l:item, 'bufnr') || l:item.bufnr == 0
            continue
        endif
        let l:path = bufname(l:item.bufnr)
        if empty(l:path) | continue | endif
        
        let l:path = fnamemodify(l:path, ':p')
        
        if has_key(l:path_to_name, l:path)
            continue
        endif
        
        let l:name = fnamemodify(l:path, ':t')
        if !has_key(l:name_to_paths, l:name)
            let l:name_to_paths[l:name] = []
        endif
        call add(l:name_to_paths[l:name], l:path)
        let l:path_to_name[l:path] = '' 
    endfor
    
    " Assign names
    for [l:name, l:paths] in items(l:name_to_paths)
        if len(l:paths) == 1
            let l:path_to_name[l:paths[0]] = l:name
        else
            let l:idx = 0
            for l:path in sort(l:paths)
                if l:idx == 0
                    let l:path_to_name[l:path] = l:name
                else
                    let l:path_to_name[l:path] = l:name . '_' . l:idx
                endif
                let l:idx += 1
            endfor
        endif
    endfor
    
    return {'file_mapping': l:path_to_name}
endfunction

function! rookie_far#QuickfixTextFunc(info) abort
    if a:info.quickfix
        let l:qflist = getqflist({'id': a:info.id, 'items': 1, 'context': 1})
    else
        let l:qflist = getloclist(a:info.winid, {'id': a:info.id, 'items': 1, 'context': 1})
    endif
    
    let l:ctx = get(l:qflist, 'context', {})
    let l:mapping = get(l:ctx, 'file_mapping', {})
    let l:items = l:qflist.items
    let l:start_idx = a:info.start_idx - 1
    let l:end_idx = a:info.end_idx - 1
    let l:res = []
    
    for l:i in range(l:start_idx, l:end_idx)
        let l:item = l:items[l:i]
        
        if l:item.valid
            let l:fname = ''
            if l:item.bufnr > 0
                let l:full_path = fnamemodify(bufname(l:item.bufnr), ':p')
                let l:fname = get(l:mapping, l:full_path, fnamemodify(l:full_path, ':t'))
            endif
            
            " Format: fname|lnum col| text
            let l:text = printf('%s|%d col %d| %s', l:fname, l:item.lnum, l:item.col, l:item.text)
        else
            let l:text = l:item.text
        endif
        
        call add(l:res, l:text)
    endfor
    
    return l:res
endfunction
