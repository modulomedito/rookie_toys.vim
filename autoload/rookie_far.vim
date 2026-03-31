vim9script
# scriptencoding utf-8

var last_pattern = ''
var last_replace = ''
var last_flags = {}
var last_changed_files = []

def ConstructVimPattern(pattern: string, flags: dict<any>): string
    var vim_pattern = ''

    # Regex vs Literal
    if flags.r
        vim_pattern ..= '\v'
    else
        vim_pattern ..= '\V'
    endif

    # Whole Word
    if flags.w
        vim_pattern ..= '\<' .. pattern .. '\>'
    else
        vim_pattern ..= pattern
    endif

    # Case Sensitivity
    if flags.c
        vim_pattern ..= '\C'
    else
        # Smart case behavior mimic
        if pattern =~# '[A-Z]'
            vim_pattern ..= '\C'
        else
            vim_pattern ..= '\c'
        endif
    endif

    return vim_pattern
enddef

# Parse arguments: handles -c, -w, -r flags
def ParseArgs(args: list<string>): dict<any>
    var flags = {c: false, w: false, r: false}
    var positional = []
    var stop_flags = false

    for arg in args
        if stop_flags
            add(positional, arg)
            continue
        endif

        if arg == '--'
            stop_flags = true
            continue
        endif

        if arg =~# '^-' && len(arg) > 1
            if arg =~# 'c' | flags.c = true | endif
            if arg =~# 'w' | flags.w = true | endif
            if arg =~# 'r' | flags.r = true | endif
        else
            add(positional, arg)
        endif
    endfor
    return {flags: flags, args: positional}
enddef

# Find only
export def Find(...args: list<string>)
    var parsed = ParseArgs(args)
    var pattern = get(parsed.args, 0, '')
    var file_mask = get(parsed.args, 1, '')

    RunSearch(pattern, file_mask, parsed.flags, '', true)
enddef

# Find and prepare for Replace
export def Replace(...args: list<string>)
    var parsed = ParseArgs(args)
    var pattern = get(parsed.args, 0, '')
    var replace_with = get(parsed.args, 1, '')
    var file_mask = get(parsed.args, 2, '')

    last_pattern = pattern
    last_replace = replace_with
    last_flags = parsed.flags

    RunSearch(pattern, file_mask, parsed.flags, replace_with, false)

    if len(getqflist()) > 0
        echo "RookieFar: Found matches. Run :RookieFarDo to execute replacement."
    endif
enddef

# Execute the replacement
export def Do()
    if empty(last_pattern)
        echoerr "RookieFar: No search pattern defined."
        return
    endif

    var pattern = last_pattern
    var replace = last_replace
    var flags = last_flags

    # Construct Vim pattern based on flags
    var vim_pattern = ConstructVimPattern(pattern, flags)

    # Escape delimiter / for substitute command
    var safe_pattern = substitute(vim_pattern, '/', '\\/', 'g')
    var safe_replace = substitute(replace, '/', '\\/', 'g')

    var cmd = 'cfdo %s/' .. safe_pattern .. '/' .. safe_replace .. '/ge | update'

    # Save files for Undo
    last_changed_files = []
    var qf_list = getqflist()
    var seen_buffers = {}
    for item in qf_list
        if has_key(item, 'bufnr') && item.bufnr > 0 && !has_key(seen_buffers, item.bufnr)
            seen_buffers[item.bufnr] = 1
            add(last_changed_files, fnamemodify(bufname(item.bufnr), ':p'))
        endif
    endfor

    var original_win = winnr()
    var original_buf = bufnr('%')
    var save_view = winsaveview()

    # If we are in quickfix window, try to find the target window (previous window)
    if &buftype == 'quickfix'
        wincmd p
        original_win = winnr()
        original_buf = bufnr('%')
        save_view = winsaveview()
    endif

    try
        execute cmd

        # Ensure we are in the original window (or a non-quickfix window)
        if &buftype == 'quickfix'
            wincmd p
        endif

        if bufnr('%') != original_buf
             if bufexists(original_buf)
                 execute 'buffer ' .. original_buf
             endif
        endif
        winrestview(save_view)

        cclose
        echo "RookieFar: Replacement complete. Use :RookieFarUndo to undo."
    catch
        echoerr "RookieFar: Replacement failed: " .. v:exception
    endtry
enddef

export def Undo()
    if empty(last_changed_files)
        echo "RookieFar: Nothing to undo."
        return
    endif

    for file in last_changed_files
        if filereadable(file)
            execute 'edit ' .. fnameescape(file)
            try
                execute 'undo'
                execute 'update'
            catch
                echoerr "RookieFar: Failed to undo in " .. file .. ": " .. v:exception
            endtry
        endif
    endfor

    echo "RookieFar: Undo complete."
    last_changed_files = []
enddef

def RunSearch(pattern: string, file_mask: string, flags: dict<any>, replace_with: string, is_find_only: bool)
    var rg_opts = '--vimgrep --no-heading --hidden'

    # Case Sensitive
    if flags.c
        rg_opts ..= ' -s'
    else
        rg_opts ..= ' --smart-case'
    endif

    # Whole Word
    if flags.w
        rg_opts ..= ' -w'
    endif

    # Regex vs Fixed String
    if !flags.r
        rg_opts ..= ' -F'
    endif

    var cmd = 'rg ' .. rg_opts .. ' -e ' .. shellescape(pattern)

    if !empty(file_mask)
        if file_mask =~# '[*?\[]'
             cmd ..= ' -g ' .. shellescape(file_mask)
        else
             cmd ..= ' ' .. shellescape(file_mask)
        endif
    endif

    var grep_output = system(cmd)

    var old_efm = &efm
    &efm = '%f:%l:%c:%m'
    try
        cgetexpr grep_output
    finally
        &efm = old_efm
    endtry

    var qf_list = getqflist()
    if len(qf_list) > 0
        var ctx = ComputeFileMapping(qf_list)
        ctx.pattern = pattern
        ctx.replace_with = replace_with
        ctx.is_find_only = is_find_only
        setqflist([], 'r', {context: ctx, quickfixtextfunc: 'rookie_far#QuickfixTextFunc'})
        copen
        wincmd p

        # Set search register for highlighting (referencing rookie_rg pattern)
        if !empty(pattern)
            @/ = ConstructVimPattern(pattern, flags)
            # Add to history and set direction to trigger highlighting reliably
            histadd("search", @/)
            v:searchforward = 1
            set hlsearch
            redraw!
            # Force highligthing update by simulating a no-op search key sequence
            # This is the most reliable way to force hlsearch to show up immediately
            feedkeys("nN", 'n')
        endif
    else
        cclose
        redraw
        echo "RookieFar: No matches found."
    endif
enddef

def ComputeFileMapping(items: list<dict<any>>): dict<any>
    var path_to_name = {}
    var name_to_paths = {}

    # Collect all paths
    for item in items
        if !has_key(item, 'bufnr') || item.bufnr == 0
            continue
        endif
        var path = bufname(item.bufnr)
        if empty(path) | continue | endif

        path = fnamemodify(path, ':p')

        if has_key(path_to_name, path)
            continue
        endif

        var name = fnamemodify(path, ':t')
        if !has_key(name_to_paths, name)
            name_to_paths[name] = []
        endif
        add(name_to_paths[name], path)
        path_to_name[path] = ''
    endfor

    # Assign names
    for [name, paths] in items(name_to_paths)
        if len(paths) == 1
            path_to_name[paths[0]] = name
        else
            var idx = 0
            for path in sort(paths)
                if idx == 0
                    path_to_name[path] = name
                else
                    path_to_name[path] = name .. '_' .. idx
                endif
                idx += 1
            endfor
        endif
    endfor

    return {file_mapping: path_to_name}
enddef

export def QuickfixTextFunc(info: dict<any>): list<string>
    var qflist: dict<any>
    if info.quickfix
        qflist = getqflist({id: info.id, items: 1, context: 1})
    else
        qflist = getloclist(info.winid, {id: info.id, items: 1, context: 1})
    endif

    var ctx = get(qflist, 'context', {})
    var mapping = get(ctx, 'file_mapping', {})
    var pattern = get(ctx, 'pattern', '')
    var replace_with = get(ctx, 'replace_with', '')
    var is_find_only = get(ctx, 'is_find_only', false)
    var items_list = qflist.items
    var start_idx = info.start_idx - 1
    var end_idx = info.end_idx - 1
    var res = []

    for i in range(start_idx, end_idx)
        var item = items_list[i]

        if item.valid
            var fname = ''
            if item.bufnr > 0
                var full_path = fnamemodify(bufname(item.bufnr), ':p')
                fname = get(mapping, full_path, fnamemodify(full_path, ':t'))
            endif

            # Format: fname|lnum col| text [NEW: replace]
            var suffix = ''
            if !is_find_only
                if !empty(replace_with)
                    suffix = ' [NEW: ' .. replace_with .. ']'
                else
                    suffix = ' (old: ' .. pattern .. ')'
                endif
            endif
            var text = printf('%s|%d col %d| %s%s', fname, item.lnum, item.col, item.text, suffix)
            add(res, text)
        else
            add(res, item.text)
        endif
    endfor

    return res
enddef


export def VisualFind()
    var saved_reg = getreg('v')
    var saved_regtype = getregtype('v')
    normal! gv"vy
    var text = substitute(@v, '[\r\n]\+$', '', '')
    setreg('v', saved_reg, saved_regtype)
    # Clean up text (remove trailing newlines if any, though usually we want exact)
    # We will pass it directly
    Find('-c', text)
enddef

export def Setup()
    nnoremap <leader>gg :RookieFarFind -cw <c-r><c-w><cr>
    vnoremap <leader>gg :<C-u>call rookie_far#VisualFind()<CR>
    nnoremap <leader>gf :RookieFarFind<Space>
enddef
