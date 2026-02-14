scriptencoding utf-8

let s:last_pattern = ''
let s:last_replace = ''
let s:last_flags = {}
let s:last_changed_files = []

" Parse arguments: handles -c, -w, -r flags
function! s:ParseArgs(args)
    let l:flags = {'c': 0, 'w': 0, 'r': 0}
    let l:positional = []
    let l:stop_flags = 0
    
    for l:arg in a:args
        if l:stop_flags
            call add(l:positional, l:arg)
            continue
        endif
        
        if l:arg == '--'
            let l:stop_flags = 1
            continue
        endif
        
        if l:arg =~# '^-' && len(l:arg) > 1
            if l:arg =~# 'c' | let l:flags.c = 1 | endif
            if l:arg =~# 'w' | let l:flags.w = 1 | endif
            if l:arg =~# 'r' | let l:flags.r = 1 | endif
        else
            call add(l:positional, l:arg)
        endif
    endfor
    return {'flags': l:flags, 'args': l:positional}
endfunction

" Find only
function! rookie_far#Find(...) abort
    let l:parsed = s:ParseArgs(a:000)
    let l:pattern = get(l:parsed.args, 0, '')
    let l:file_mask = get(l:parsed.args, 1, '')
    call s:RunSearch(l:pattern, l:file_mask, l:parsed.flags, '')
endfunction

" Find and prepare for Replace
function! rookie_far#Replace(...) abort
    let l:parsed = s:ParseArgs(a:000)
    let l:pattern = get(l:parsed.args, 0, '')
    let l:replace_with = get(l:parsed.args, 1, '')
    let l:file_mask = get(l:parsed.args, 2, '')

    let s:last_pattern = l:pattern
    let s:last_replace = l:replace_with
    let s:last_flags = l:parsed.flags
    
    call s:RunSearch(l:pattern, l:file_mask, l:parsed.flags, l:replace_with)
    
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
    let l:flags = s:last_flags
    
    " Construct Vim pattern based on flags
    let l:vim_pattern = ''
    
    " Regex vs Literal
    if l:flags.r
        let l:vim_pattern .= '\v'
    else
        let l:vim_pattern .= '\V'
    endif
    
    " Whole Word
    if l:flags.w
        let l:vim_pattern .= '\<' . l:pattern . '\>'
    else
        let l:vim_pattern .= l:pattern
    endif
    
    " Case Sensitivity
    if l:flags.c
        let l:vim_pattern .= '\C'
    else
        " Use \c only if pattern doesn't contain uppercase (smart case behavior mimic)
        " Or just rely on user setting? 
        " User requirement: if -c then sensitive. Implicitly if not -c, then ignore/smart.
        " Safest to force \c if not sensitive to ensure matches are found if rg found them case-insensitively.
        " But if rg used smart case and found "Foo" because pattern was "Foo", 
        " we should probably respect that.
        " Let's check for uppercase if not strict.
        if l:pattern =~# '[A-Z]'
             let l:vim_pattern .= '\C'
        else
             let l:vim_pattern .= '\c'
        endif
    endif

    " Escape delimiter / for substitute command
    let l:safe_pattern = substitute(l:vim_pattern, '/', '\\/', 'g')
    let l:safe_replace = substitute(l:replace, '/', '\\/', 'g')
    
    let l:cmd = 'cfdo %s/' . l:safe_pattern . '/' . l:safe_replace . '/ge | update'
    
    " Save files for Undo
    let s:last_changed_files = []
    let l:qf_list = getqflist()
    let l:seen_buffers = {}
    for l:item in l:qf_list
        if has_key(l:item, 'bufnr') && l:item.bufnr > 0 && !has_key(l:seen_buffers, l:item.bufnr)
            let l:seen_buffers[l:item.bufnr] = 1
            call add(s:last_changed_files, fnamemodify(bufname(l:item.bufnr), ':p'))
        endif
    endfor

    try
        execute l:cmd
        cclose
        echo "RookieFar: Replacement complete. Use :RookieFarUndo to undo."
    catch
        echoerr "RookieFar: Replacement failed: " . v:exception
    endtry
endfunction

function! rookie_far#Undo() abort
    if empty(s:last_changed_files)
        echo "RookieFar: Nothing to undo."
        return
    endif
    
    for l:file in s:last_changed_files
        if filereadable(l:file)
            execute 'edit ' . fnameescape(l:file)
            try
                execute 'undo'
                execute 'update'
            catch
                echoerr "RookieFar: Failed to undo in " . l:file . ": " . v:exception
            endtry
        endif
    endfor
    
    echo "RookieFar: Undo complete."
    let s:last_changed_files = [] 
endfunction

function! s:RunSearch(pattern, file_mask, flags, replace_with)
    let l:pattern = a:pattern
    let l:rg_opts = '--vimgrep --no-heading --hidden'
    let l:search_flag = ''
    
    " Case Sensitive
    if a:flags.c
        let l:rg_opts .= ' -s'
        let l:search_flag .= '\C'
    else
        let l:rg_opts .= ' --smart-case'
        " For highlighting:
        if l:pattern =~# '[A-Z]'
            let l:search_flag .= '\C'
        else
            let l:search_flag .= '\c'
        endif
    endif
    
    " Whole Word
    if a:flags.w
        let l:rg_opts .= ' -w'
    endif
    
    " Regex vs Fixed String
    if !a:flags.r
        let l:rg_opts .= ' -F'
        let l:search_flag = '\V' . l:search_flag
    else
        let l:search_flag = '\v' . l:search_flag
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
        let l:ctx.pattern = l:pattern
        let l:ctx.replace_with = a:replace_with
        call setqflist([], 'r', {'context': l:ctx, 'quickfixtextfunc': 'rookie_far#QuickfixTextFunc'})
        copen
        
        " Set search register for highlighting
        " Combine regex mode prefix, case flag, and pattern
        if a:flags.w
             " Vim highlighting for whole word
             if a:flags.r
                 let @/ = l:search_flag . '\<' . l:pattern . '\>'
             else
                 " Literal whole word search in vim is tricky with \V
                 " \V\<pattern\> works
                 let @/ = l:search_flag . '\<' . l:pattern . '\>'
             endif
        else
             let @/ = l:search_flag . l:pattern
        endif
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
    let l:pattern = get(l:ctx, 'pattern', '')
    let l:replace_with = get(l:ctx, 'replace_with', '')
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
            
            " Format: fname|lnum col| text [NEW: replace]
            let l:suffix = ''
            if !empty(l:replace_with)
                let l:suffix = ' [NEW: ' . l:replace_with . ']'
            else
                let l:suffix = ' (old: ' . l:pattern . ')'
            endif
            let l:text = printf('%s|%d col %d| %s%s', l:fname, l:item.lnum, l:item.col, l:item.text, l:suffix)
        else
            let l:text = l:item.text
        endif
        
        call add(l:res, l:text)
    endfor
    
    return l:res
endfunction
