" autoload/rookie_rust.vim

function! rookie_rust#TestFunctionUnderCursor() abort
    " 1. Find Cargo.toml to determine Crate Name and Root
    let l:cargo_toml = findfile('Cargo.toml', '.;')
    if empty(l:cargo_toml)
        echoerr "rookie_rust: Cargo.toml not found in parent directories."
        return
    endif
    let l:cargo_root = fnamemodify(l:cargo_toml, ':p:h')

    " Parse Crate Name
    let l:lines = readfile(l:cargo_toml)
    let l:crate_name = ''
    let l:in_package = 0
    for l:line in l:lines
        if l:line =~# '^\s*\[package\]'
            let l:in_package = 1
        elseif l:line =~# '^\s*\[.*\]'
            let l:in_package = 0
        endif

        if l:in_package && l:line =~# '^\s*name\s*='
            " Extract name="value" or name = "value"
            let l:crate_name = matchstr(l:line, 'name\s*=\s*"\zs[^"]\+\ze"')
            if !empty(l:crate_name)
                break
            endif
        endif
    endfor

    if empty(l:crate_name)
        echoerr "rookie_rust: Could not determine crate name from " . l:cargo_toml
        return
    endif

    " 2. Determine Module Path from File Structure
    let l:file_path = expand('%:p')
    " Get path relative to cargo root
    let l:rel_path = l:file_path[len(l:cargo_root)+1:]
    " Normalize separators
    let l:rel_path = substitute(l:rel_path, '\\', '/', 'g')

    let l:mod_path = ''
    if l:rel_path =~# '^src/'
        let l:temp = l:rel_path[4:] " Strip src/
        let l:temp = fnamemodify(l:temp, ':r') " Strip extension

        " Handle mod.rs convention: dir/mod.rs -> dir
        if l:temp =~# '/mod$' || l:temp ==# 'mod'
            let l:temp = fnamemodify(l:temp, ':h')
            if l:temp ==# '.' " handled if it was just 'mod.rs' in src
                let l:temp = ''
            endif
        endif

        " Handle lib.rs / main.rs -> empty module path (root)
        if l:temp ==# 'lib' || l:temp ==# 'main'
            let l:temp = ''
        endif

        let l:mod_path = substitute(l:temp, '/', '::', 'g')
    else
        " Files outside src/ (e.g. tests/ or examples/)
        let l:temp = fnamemodify(l:rel_path, ':r')
        let l:mod_path = substitute(l:temp, '/', '::', 'g')
    endif

    " 3. Find Function Name
    let l:save_view = winsaveview()
    " Search backwards for function definition
    " Regex matches: fn <name>
    " Should handle optional pub/async/unsafe etc.
    let l:func_lnum = search('^\s*\(pub\s\+\|async\s\+\|unsafe\s\+\|extern\s\+\)*fn\s\+\w\+', 'bcnW')

    if l:func_lnum == 0
        echoerr "rookie_rust: No function definition found under/above cursor."
        return
    endif

    let l:func_line = getline(l:func_lnum)
    let l:func_name = matchstr(l:func_line, 'fn\s\+\zs\w\+')

    " 4. Find Parent Modules (in-file)
    " Move to function line to start search
    call cursor(l:func_lnum, 1)
    let l:modules = []

    while 1
        " Find enclosing brace '{' backwards
        let l:brace_lnum = searchpair('{', '', '}', 'bW')
        if l:brace_lnum == 0
            break
        endif

        " Check if this brace belongs to a 'mod' definition
        let l:line_content = getline(l:brace_lnum)
        let l:mod_name = ''

        " Check same line: 'mod tests {'
        if l:line_content =~# 'mod\s\+\w\+'
            let l:mod_name = matchstr(l:line_content, 'mod\s\+\zs\w\+')
        else
            " Check previous line (if brace is on new line)
            let l:prev_line = getline(l:brace_lnum - 1)
            if l:prev_line =~# 'mod\s\+\w\+'
                let l:mod_name = matchstr(l:prev_line, 'mod\s\+\zs\w\+')
            endif
        endif

        if !empty(l:mod_name)
            call insert(l:modules, l:mod_name)
        endif
        " Loop continues from l:brace_lnum to find *its* parent
    endwhile

    call winrestview(l:save_view)

    " 5. Construct Full Test Path
    let l:full_path = l:mod_path

    for l:m in l:modules
        if !empty(l:full_path)
            let l:full_path .= '::'
        else
            let l:full_path = l:m " If mod_path empty, start with first module
            continue
        endif
        let l:full_path .= l:m
    endfor

    if !empty(l:full_path)
        let l:full_path .= '::' . l:func_name
    else
        let l:full_path = l:func_name
    endif

    " 6. Build and Run Command
    " User requested format:
    " copen | AsyncRun cargo test -p ACrate --test dir1::dir2::srcfile::test::test_something -- --nocapture

    let l:cmd_core = 'cargo test -p ' . l:crate_name . ' ' . l:full_path . ' -- --nocapture'

    if exists(':AsyncRun')
        let l:final_cmd = 'copen | AsyncRun ' . l:cmd_core
    else
        let l:final_cmd = '!' . l:cmd_core
    endif

    " Populate command line and wait for User <CR>
    call feedkeys(':' . l:final_cmd, 'n')

endfunction
