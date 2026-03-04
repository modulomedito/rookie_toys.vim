scriptencoding utf-8

function! s:ProcessAnsi(lines) abort
    let l:clean_lines = []
    let l:matches = []

    let l:color_map = {
        \ '31': 'RookieGitGraphColorRed',
        \ '32': 'RookieGitGraphColorGreen',
        \ '33': 'RookieGitGraphColorYellow',
        \ '34': 'RookieGitGraphColorBlue',
        \ '35': 'RookieGitGraphColorMagenta',
        \ '36': 'RookieGitGraphColorCyan',
        \ '37': 'RookieGitGraphColorWhite',
        \ '1;31': 'RookieGitGraphColorRed',
        \ '1;32': 'RookieGitGraphColorGreen',
        \ '1;33': 'RookieGitGraphColorYellow',
        \ '1;34': 'RookieGitGraphColorBlue',
        \ '1;35': 'RookieGitGraphColorMagenta',
        \ '1;36': 'RookieGitGraphColorCyan',
        \ '1;37': 'RookieGitGraphColorWhite',
        \ }

    let l:idx = 1
    for l:line in a:lines
        let l:new_line = ''
        let l:line_matches = []
        let l:current_hl = ''
        let l:col = 1

        let l:remaining = l:line
        let l:in_graph = 1
        while !empty(l:remaining)
            let l:start = match(l:remaining, '\e\[[0-9;]*m')

            if l:start == -1
                let l:text = l:remaining

                if l:in_graph
                    let l:non_graph_idx = match(l:text, '[^|\\/ _*]')
                    if l:non_graph_idx == -1
                        let l:text = substitute(l:text, '|', '│', 'g')
                    else
                        let l:graph_part = strpart(l:text, 0, l:non_graph_idx)
                        let l:rest_part = strpart(l:text, l:non_graph_idx)
                        let l:graph_part = substitute(l:graph_part, '|', '│', 'g')
                        let l:text = l:graph_part . l:rest_part
                        let l:in_graph = 0
                    endif
                endif

                let l:new_line .= l:text
                if !empty(l:current_hl)
                    call add(l:line_matches, [l:current_hl, l:idx, l:col, len(l:text)])
                endif
                break
            endif

            if l:start > 0
                let l:text = strpart(l:remaining, 0, l:start)

                if l:in_graph
                    let l:non_graph_idx = match(l:text, '[^|\\/ _*]')
                    if l:non_graph_idx == -1
                        let l:text = substitute(l:text, '|', '│', 'g')
                    else
                        let l:graph_part = strpart(l:text, 0, l:non_graph_idx)
                        let l:rest_part = strpart(l:text, l:non_graph_idx)
                        let l:graph_part = substitute(l:graph_part, '|', '│', 'g')
                        let l:text = l:graph_part . l:rest_part
                        let l:in_graph = 0
                    endif
                endif

                let l:new_line .= l:text
                if !empty(l:current_hl)
                    call add(l:line_matches, [l:current_hl, l:idx, l:col, len(l:text)])
                endif
                let l:col += len(l:text)
            endif

            let l:match_str = matchstr(l:remaining, '^\e\[[0-9;]*m', l:start)
            let l:code = matchstr(l:match_str, '\e\[\zs[0-9;]*\ze')
            " Remove trailing m if caught by regex above or simplify
            let l:code = substitute(l:code, 'm$', '', '')

            if has_key(l:color_map, l:code)
                let l:current_hl = l:color_map[l:code]
            elseif l:code ==# '0' || l:code ==# ''
                let l:current_hl = ''
            else
                " Try to handle codes like 31;1 or 1;31 more robustly
                let l:parts = split(l:code, ';')
                call sort(l:parts)
                let l:sorted_code = join(l:parts, ';')
                if has_key(l:color_map, l:sorted_code)
                    let l:current_hl = l:color_map[l:sorted_code]
                endif
            endif

            let l:remaining = strpart(l:remaining, l:start + len(l:match_str))
        endwhile

        " Post-processing: Replace * with ●
        let l:star_idx = match(l:new_line, '^\([│╲╱|\\/ _]*\)\zs\*')
        if l:star_idx != -1
            let l:before = strpart(l:new_line, 0, l:star_idx)
            let l:after = strpart(l:new_line, l:star_idx + 1)
            let l:new_line = l:before . '●' . l:after

            " Adjust matches
            for l:m in l:line_matches
                let l:m_col = l:m[2]
                let l:m_len = l:m[3]
                let l:m_end = l:m_col + l:m_len
                let l:star_col = l:star_idx + 1

                if l:m_col > l:star_col
                    let l:m[2] += 2
                elseif l:m_col <= l:star_col && l:m_end > l:star_col
                    let l:m[3] += 2
                endif
            endfor
        endif

        " Custom replacements for smoother graph
        " 1. │\ -> ├╮
        while 1
            let l:idx = match(l:new_line, '│\\')
            if l:idx == -1
                break
            endif
            let l:before = strpart(l:new_line, 0, l:idx)
            let l:after = strpart(l:new_line, l:idx + 4) " │ (3) + \ (1) = 4
            let l:new_line = l:before . '├╮' . l:after

            let l:diff = 2 " ├╮ (6) - │\ (4) = 2
            let l:match_end = l:idx + 4

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                if l:m[2] > l:match_end
                     let l:m[2] += l:diff
                endif
                let l:i += 1
            endwhile
        endwhile

        " 2. │/ -> ├╯
        while 1
            let l:idx = match(l:new_line, '│/')
            if l:idx == -1
                break
            endif
            let l:before = strpart(l:new_line, 0, l:idx)
            let l:after = strpart(l:new_line, l:idx + 4) " │ (3) + / (1) = 4
            let l:new_line = l:before . '├╯' . l:after

            let l:diff = 2 " ├╯ (6) - │/ (4) = 2
            let l:match_end = l:idx + 4

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                if l:m[2] > l:match_end
                     let l:m[2] += l:diff
                endif
                let l:i += 1
            endwhile
        endwhile

        " 10. ● / -> ●│ (Remove spaces and replace char)
        while 1
            let l:idx = match(l:new_line, '●\zs \+\ze/')
            if l:idx == -1
                break
            endif

            let l:spaces = matchstr(l:new_line, '●\zs \+\ze/')
            let l:num_spaces = len(l:spaces)

            let l:before = strpart(l:new_line, 0, l:idx)
            let l:after = strpart(l:new_line, l:idx + l:num_spaces + 1) " Skip spaces and / (1 byte)
            let l:new_line = l:before . '│' . l:after

            let l:space_col_start = l:idx + 1
            let l:space_col_end = l:space_col_start + l:num_spaces

            " ● (3) + spaces (N) + / (1) -> ● (3) + │ (3)
            " Removed N + 1 bytes. Added 3 bytes.
            " Net change: 3 - (N + 1) = 2 - N
            let l:diff = 2 - l:num_spaces

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                let l:m_col = l:m[2]
                let l:m_len = l:m[3]
                let l:m_end = l:m_col + l:m_len

                " Check overlap with spaces (unlikely for colored matches but safe to check)
                let l:overlap_start = (l:m_col > l:space_col_start) ? l:m_col : l:space_col_start
                let l:overlap_end = (l:m_end < l:space_col_end) ? l:m_end : l:space_col_end
                let l:overlap_len = l:overlap_end - l:overlap_start

                if l:overlap_len > 0
                    let l:m[3] -= l:overlap_len
                endif

                if l:m_col >= l:space_col_end
                    let l:m[2] += l:diff
                elseif l:m_col > l:space_col_start
                    let l:m[2] = l:space_col_start
                endif

                if l:m[3] <= 0
                    call remove(l:line_matches, l:i)
                    continue
                endif
                let l:i += 1
            endwhile
        endwhile

        " 3. │ ● -> │● (Remove space)
        while 1
            let l:idx = match(l:new_line, '│ ●')
            if l:idx == -1
                break
            endif

            let l:before = strpart(l:new_line, 0, l:idx + 3) " Keep │ (3 bytes)
            let l:after = strpart(l:new_line, l:idx + 4)     " Skip space
            let l:new_line = l:before . l:after

            let l:space_col = l:idx + 4

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                let l:m_col = l:m[2]
                let l:m_len = l:m[3]
                let l:m_end = l:m_col + l:m_len

                if l:m_col > l:space_col
                    let l:m[2] -= 1
                elseif l:m_col <= l:space_col && l:m_end > l:space_col
                    let l:m[3] -= 1
                endif

                if l:m[3] <= 0
                    call remove(l:line_matches, l:i)
                    continue
                endif
                let l:i += 1
            endwhile
        endwhile

        " 8. │ ├╯ -> │├╯ (Remove space)
        while 1
            let l:idx = match(l:new_line, '│ ├╯')
            if l:idx == -1
                break
            endif

            let l:before = strpart(l:new_line, 0, l:idx + 3) " Keep │ (3 bytes)
            let l:after = strpart(l:new_line, l:idx + 4)     " Skip space
            let l:new_line = l:before . l:after

            let l:space_col = l:idx + 4

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                let l:m_col = l:m[2]
                let l:m_len = l:m[3]
                let l:m_end = l:m_col + l:m_len

                if l:m_col > l:space_col
                    let l:m[2] -= 1
                elseif l:m_col <= l:space_col && l:m_end > l:space_col
                    let l:m[3] -= 1
                endif

                if l:m[3] <= 0
                    call remove(l:line_matches, l:i)
                    continue
                endif
                let l:i += 1
            endwhile
        endwhile

        " 5. │ ├╮ -> │├╮ (Remove space)
        while 1
            let l:idx = match(l:new_line, '│ ├╮')
            if l:idx == -1
                break
            endif

            let l:before = strpart(l:new_line, 0, l:idx + 3) " Keep │ (3 bytes)
            let l:after = strpart(l:new_line, l:idx + 4)     " Skip space
            let l:new_line = l:before . l:after

            let l:space_col = l:idx + 4

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                let l:m_col = l:m[2]
                let l:m_len = l:m[3]
                let l:m_end = l:m_col + l:m_len

                if l:m_col > l:space_col
                    let l:m[2] -= 1
                elseif l:m_col <= l:space_col && l:m_end > l:space_col
                    let l:m[3] -= 1
                endif

                if l:m[3] <= 0
                    call remove(l:line_matches, l:i)
                    continue
                endif
                let l:i += 1
            endwhile
        endwhile

        " 6. │ │● -> ││● (Remove space)
        while 1
            let l:idx = match(l:new_line, '│ │●')
            if l:idx == -1
                break
            endif

            let l:before = strpart(l:new_line, 0, l:idx + 3) " Keep │ (3 bytes)
            let l:after = strpart(l:new_line, l:idx + 4)     " Skip space
            let l:new_line = l:before . l:after

            let l:space_col = l:idx + 4

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                let l:m_col = l:m[2]
                let l:m_len = l:m[3]
                let l:m_end = l:m_col + l:m_len

                if l:m_col > l:space_col
                    let l:m[2] -= 1
                elseif l:m_col <= l:space_col && l:m_end > l:space_col
                    let l:m[3] -= 1
                endif

                if l:m[3] <= 0
                    call remove(l:line_matches, l:i)
                    continue
                endif
                let l:i += 1
            endwhile
        endwhile

        " 7. ●│ │ -> ●││ (Remove space)
        while 1
            let l:idx = match(l:new_line, '●│ │')
            if l:idx == -1
                break
            endif

            let l:before = strpart(l:new_line, 0, l:idx + 6) " Keep ●│ (3+3=6 bytes)
            let l:after = strpart(l:new_line, l:idx + 7)     " Skip space
            let l:new_line = l:before . l:after

            let l:space_col = l:idx + 7

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                let l:m_col = l:m[2]
                let l:m_len = l:m[3]
                let l:m_end = l:m_col + l:m_len

                if l:m_col > l:space_col
                    let l:m[2] -= 1
                elseif l:m_col <= l:space_col && l:m_end > l:space_col
                    let l:m[3] -= 1
                endif

                if l:m[3] <= 0
                    call remove(l:line_matches, l:i)
                    continue
                endif
                let l:i += 1
            endwhile
        endwhile

        " 4. ● │ -> ●│ (Remove space)
        while 1
            let l:idx = match(l:new_line, '● │')
            if l:idx == -1
                break
            endif

            let l:before = strpart(l:new_line, 0, l:idx + 3) " Keep ● (3 bytes)
            let l:after = strpart(l:new_line, l:idx + 4)     " Skip space
            let l:new_line = l:before . l:after

            let l:space_col = l:idx + 4

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                let l:m_col = l:m[2]
                let l:m_len = l:m[3]
                let l:m_end = l:m_col + l:m_len

                if l:m_col > l:space_col
                    let l:m[2] -= 1
                elseif l:m_col <= l:space_col && l:m_end > l:space_col
                    let l:m[3] -= 1
                endif

                if l:m[3] <= 0
                    call remove(l:line_matches, l:i)
                    continue
                endif
                let l:i += 1
            endwhile
        endwhile

        " 9. ● <sha> -> ●<sha> (Remove spaces)
        while 1
            " Match spaces between graph chars and hex digit
            " Graph chars: │ ╲ ╱ ● ├ ╮ ╯ _
            " Use \zs to get index of first space
            let l:idx = match(l:new_line, '[│╲╱●├╮╯_]\zs \+\ze[a-f0-9]')
            if l:idx == -1
                break
            endif

            let l:spaces = matchstr(l:new_line, '[│╲╱●├╮╯_]\zs \+\ze[a-f0-9]')
            let l:num_spaces = len(l:spaces)

            let l:before = strpart(l:new_line, 0, l:idx)
            let l:after = strpart(l:new_line, l:idx + l:num_spaces)
            let l:new_line = l:before . l:after

            let l:space_col_start = l:idx + 1
            let l:space_col_end = l:space_col_start + l:num_spaces

            let l:i = 0
            while l:i < len(l:line_matches)
                let l:m = l:line_matches[l:i]
                let l:m_col = l:m[2]
                let l:m_len = l:m[3]
                let l:m_end = l:m_col + l:m_len

                " Calculate overlap with removed region [space_col_start, space_col_end)
                let l:overlap_start = (l:m_col > l:space_col_start) ? l:m_col : l:space_col_start
                let l:overlap_end = (l:m_end < l:space_col_end) ? l:m_end : l:space_col_end
                let l:overlap_len = l:overlap_end - l:overlap_start

                if l:overlap_len > 0
                    let l:m[3] -= l:overlap_len
                endif

                if l:m_col >= l:space_col_end
                    let l:m[2] -= l:num_spaces
                elseif l:m_col > l:space_col_start
                    let l:m[2] = l:space_col_start
                endif

                if l:m[3] <= 0
                    call remove(l:line_matches, l:i)
                    continue
                endif
                let l:i += 1
            endwhile
        endwhile

        call add(l:clean_lines, l:new_line)
        call extend(l:matches, l:line_matches)
        let l:idx += 1
    endfor

    " 11. Complex Merge Pattern Fix
    " Pattern:
    "   │├╯
    "   ●│...
    "   ├╮│
    " Replace with:
    "   │││
    "   ●││...
    "   ├┼╯
    let l:i = 0
    while l:i < len(l:clean_lines) - 2
        let l:line1 = l:clean_lines[l:i]
        let l:line2 = l:clean_lines[l:i+1]
        let l:line3 = l:clean_lines[l:i+2]

        " Use match() to check patterns
        " Line 1: Ends with │├╯ (ignoring trailing spaces)
        if match(l:line1, '│├╯\s*$') != -1
            " Line 2: Starts with ●│ followed by hex
            if match(l:line2, '^●│[a-f0-9]') != -1
                " Line 3: Starts with ├╮│
                if match(l:line3, '^├╮│') != -1
                    " Apply replacements

                    " Line 1: Replace │├╯ with │││
                    let l:clean_lines[l:i] = substitute(l:line1, '│├╯', '│││', '')

                    " Line 2: Insert │ after ●│
                    " ● (3 bytes) + │ (3 bytes) = 6 bytes
                    let l:before = strpart(l:line2, 0, 6)
                    let l:after = strpart(l:line2, 6)
                    let l:clean_lines[l:i+1] = l:before . '│' . l:after

                    " Update matches for Line 2 (index l:i + 2 because matches are 1-based)
                    let l:match_line_idx = l:i + 2
                    let l:insert_pos = 7
                    let l:diff = 3

                    for l:m in l:matches
                        if l:m[1] == l:match_line_idx
                            if l:m[2] >= l:insert_pos
                                let l:m[2] += l:diff
                            endif
                        endif
                    endfor

                    " Line 3: Replace ├╮│ with ├┼╯
                    let l:clean_lines[l:i+2] = substitute(l:line3, '├╮│', '├┼╯', '')
                endif
            endif
        endif
        let l:i += 1
    endwhile

    return [l:clean_lines, l:matches]
endfunction

function! s:GetGitDir(dir) abort
    let l:git_dir = system('git -C ' . shellescape(a:dir) . ' rev-parse --git-dir')
    let l:git_dir = substitute(l:git_dir, '\n$', '', '')
    if v:shell_error
        return ''
    endif
    " If relative path, resolve to absolute
    if l:git_dir !~# '^/' && l:git_dir !~# '^[a-zA-Z]:'
        let l:git_dir = fnamemodify(a:dir . '/' . l:git_dir, ':p')
        " Remove trailing slash/newline
        let l:git_dir = substitute(l:git_dir, '[/\\]\+$', '', '')
    endif
    return l:git_dir
endfunction

function! s:IsFetchNeeded(dir) abort
    let l:git_dir = s:GetGitDir(a:dir)
    if empty(l:git_dir)
        return 1
    endif

    let l:fetch_head = l:git_dir . '/FETCH_HEAD'
    let l:last_fetch = getftime(l:fetch_head)

    if l:last_fetch == -1
        return 1
    endif

    " Default timeout 60 seconds
    let l:timeout = get(g:, 'rookie_gitgraph_fetch_timeout', 60)
    let l:now = localtime()

    if (l:now - l:last_fetch) < l:timeout
        return 0
    endif

    return 1
endfunction

function! s:UpdateGraphCallback(bufnr, cmd, ...) abort
    let l:report_update = get(a:000, 0, 0)

    if !bufexists(a:bufnr)
        return
    endif

    let l:output = systemlist(a:cmd)

    let [l:clean_lines, l:matches] = s:ProcessAnsi(l:output)

    " Check if content has changed
    let l:current_content = getbufline(a:bufnr, 1, '$')
    if l:clean_lines ==# l:current_content
        if l:report_update
             echo "Git graph is up to date."
        endif
        return
    endif

    " Update buffer content
    call setbufvar(a:bufnr, '&modifiable', 1)
    call deletebufline(a:bufnr, 1, '$')
    call setbufline(a:bufnr, 1, l:clean_lines)

    " Apply highlighting and formatting
    let l:winid = bufwinid(a:bufnr)
    if l:winid != -1
        call win_execute(l:winid, 'setlocal nomodifiable')
        call win_execute(l:winid, 'normal! gg')
        call win_execute(l:winid, 'call clearmatches()')

        " Ensure highlight groups are defined before using matchaddpos
        call win_execute(l:winid, 'call rookie_gitgraph#HighlightRefs()')

        " Group matches by highlight group
        let l:groups = {}
        for l:m in l:matches
            let l:grp = l:m[0]
            if !has_key(l:groups, l:grp)
                let l:groups[l:grp] = []
            endif
            call add(l:groups[l:grp], [l:m[1], l:m[2], l:m[3]])
        endfor

        for [l:grp, l:pos_list] in items(l:groups)
            let l:chunk_size = 8
            for l:i in range(0, len(l:pos_list) - 1, l:chunk_size)
                let l:chunk = l:pos_list[l:i : l:i + l:chunk_size - 1]
                call win_execute(l:winid, "call matchaddpos('" . l:grp . "', " . string(l:chunk) . ")")
            endfor
        endfor

        call win_execute(l:winid, 'call search("HEAD ->")')
        call win_execute(l:winid, 'normal! zz')

        if l:report_update
            redraw
            echo "Git graph updated."
        endif
    else
        call setbufvar(a:bufnr, '&modifiable', 0)
    endif
endfunction

function! rookie_gitgraph#OpenGitGraph(all_branches) abort
    " Close existing Rookie GitGraph buffers
    for b in getbufinfo({'bufloaded': 1})
        if getbufvar(b.bufnr, 'is_rookie_gitgraph')
            execute 'bd ' . b.bufnr
        endif
    endfor

    " Open new buffer on the right
    rightbelow vnew
    execute 'vertical resize ' . float2nr(&columns * 1.0 / 2.0)

    let b:is_rookie_gitgraph = 1
    setlocal filetype=git
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal modifiable

    let l:bufnr = bufnr('%')

    " Map <CR> to show commit diff
    nnoremap <buffer> <silent> <CR> :RookieGitOpenCommitDiff<CR>

    " Determine git root
    let l:dir = getcwd()
    if exists('*FugitiveWorkTree')
        try
            let l:dir = FugitiveWorkTree()
        catch
        endtry
    endif

    " Construct git command
    let l:cmd = 'git -C ' . shellescape(l:dir) . ' log --graph --decorate --color=always '
    if a:all_branches
        let l:cmd = l:cmd . '--all '
    endif
    let l:cmd = l:cmd . '--pretty=format:"%h [%ad] {%an} |%d %s" --date=format-local:"%y-%m-%d %H:%M"'

    " Render immediately
    call s:UpdateGraphCallback(l:bufnr, l:cmd, 0)

    " Async Fetch + Callback
    if get(g:, 'rookie_gitgraph_async_fetch', 1)
        if s:IsFetchNeeded(l:dir)
            echo "Fetching updates..."
            call rookie_git#AsyncFetch(l:dir, function('s:UpdateGraphCallback', [l:bufnr, l:cmd, 1]))
        endif
    else
        " Synchronous fallback
        if s:IsFetchNeeded(l:dir)
            echo "Fetching updates..."
            if exists(':G')
                silent! execute 'G fetch'
            elseif exists(':Git')
                silent! execute 'Git fetch'
            else
                call system('git -C ' . shellescape(l:dir) . ' fetch --all --quiet')
            endif
            call s:UpdateGraphCallback(l:bufnr, l:cmd, 1)
        endif
    endif
endfunction

function! rookie_gitgraph#HighlightRefs() abort
    if !has('syntax')
        return
    endif
    silent! syntax clear RookieGitGraphDecorRegion
    silent! syntax clear RookieGitGraphOrigin
    silent! syntax clear RookieGitGraphHead
    silent! syntax clear RookieGitGraphBracket
    silent! syntax clear RookieGitGraphStarNormal
    silent! syntax clear RookieGitGraphStarOrigin
    silent! syntax clear RookieGitGraphStarHead
    silent! syntax clear RookieGitGraphColorRed
    silent! syntax clear RookieGitGraphColorGreen
    silent! syntax clear RookieGitGraphColorYellow
    silent! syntax clear RookieGitGraphColorBlue
    silent! syntax clear RookieGitGraphColorMagenta
    silent! syntax clear RookieGitGraphColorCyan
    silent! syntax clear RookieGitGraphColorWhite
    silent! syntax clear RookieGitGraphHash
    silent! syntax clear RookieGitGraphDate
    silent! syntax clear RookieGitGraphAuthor

    " Gruvbox Colors
    highlight RookieGitGraphColorRed     guifg=#cc241d ctermfg=124 gui=bold cterm=bold
    highlight RookieGitGraphColorGreen   guifg=#98971a ctermfg=106 gui=bold cterm=bold
    highlight RookieGitGraphColorYellow  guifg=#d79921 ctermfg=172 gui=bold cterm=bold
    highlight RookieGitGraphColorBlue    guifg=#458588 ctermfg=66  gui=bold cterm=bold
    highlight RookieGitGraphColorMagenta guifg=#b16286 ctermfg=132 gui=bold cterm=bold
    highlight RookieGitGraphColorCyan    guifg=#689d6a ctermfg=72  gui=bold cterm=bold
    highlight RookieGitGraphColorWhite   guifg=#928374 ctermfg=246 gui=bold cterm=bold

    highlight RookieGitGraphHash   guifg=#d79921 gui=NONE cterm=NONE
    highlight RookieGitGraphDate   guifg=#458588 gui=NONE cterm=NONE
    highlight RookieGitGraphAuthor guifg=#83a598 gui=NONE cterm=NONE

    highlight RookieGitGraphDecorRegion guifg=#689d6a gui=bold cterm=bold
    highlight RookieGitGraphBracket guifg=#689d6a gui=bold cterm=bold
    highlight RookieGitGraphOrigin guifg=#d65d0e gui=bold cterm=bold
    highlight RookieGitGraphHead guifg=#cc241d gui=bold cterm=bold
    highlight RookieGitGraphStarNormal guifg=#689d6a gui=bold cterm=bold
    highlight RookieGitGraphStarOrigin guifg=#d65d0e gui=bold cterm=bold
    highlight RookieGitGraphStarHead   guifg=#cc241d     gui=bold cterm=bold

    execute 'syntax region RookieGitGraphDecorRegion matchgroup=RookieGitGraphBracket start=/\v\| *\(/ end=/\v\)\s/ keepend contains=RookieGitGraphOrigin,RookieGitGraphHead'
    execute 'syntax match RookieGitGraphOrigin /\vorigin\/[^, )]+/ contained containedin=RookieGitGraphDecorRegion'
    execute 'syntax match RookieGitGraphHead /\vHEAD(\s*->\s*[^,)]+)?/ contained containedin=RookieGitGraphDecorRegion'

    " Match commit info
    syntax match RookieGitGraphHash /\v[a-f0-9]{7,}/
    syntax match RookieGitGraphDate /\v\[[^\]]+\]/
    syntax match RookieGitGraphAuthor /\v\{[^\}]+\}/

    " Match ● based on line content priority (last defined wins)
    " 3. Local/Tag/Decor (#7fbbb3) - Match if line contains '} | ('
    syntax match RookieGitGraphStarNormal /●\(.*} | (\)\@=/
    " 2. Origin (Orange) - Match if line contains 'origin/'
    syntax match RookieGitGraphStarOrigin /●\(.*origin\/\)\@=/
    " 1. HEAD (Red) - Match if line contains 'HEAD' but not 'origin/HEAD'
    syntax match RookieGitGraphStarHead   /●\(.*\(origin\/\)\@<!HEAD\)\@=/
endfunction

let g:rookie_last_git_state = ''

function! rookie_gitgraph#GetGitState() abort
    " Check relative to the current file path to avoid slow checks in non-git folders
    let l:dir = expand('%:p:h')

    " Skip optimization for special buffers (fugitive, etc.)
    if l:dir !~# '://'
        if empty(l:dir)
            let l:dir = getcwd()
        endif
        " Escape commas for finddir path argument
        let l:search_path = substitute(l:dir, ',', '\\,', 'g') . ';'

        " Check if .git directory or file exists upwards from the file's directory
        if finddir('.git', l:search_path) ==# '' && findfile('.git', l:search_path) ==# ''
            return ''
        endif
    endif

    " Check if inside a git repository
    let l:null_device = (has('win32') || has('win64')) ? 'NUL' : '/dev/null'
    let l:is_git = system('git rev-parse --is-inside-work-tree 2>' . l:null_device)
    if l:is_git !~ 'true'
        return ''
    endif
    " Capture HEAD and all refs (covers commit, checkout, pull, push, fetch, etc.)
    return system('git rev-parse HEAD 2>' . l:null_device) . system('git show-ref -s 2>' . l:null_device)
endfunction

function! rookie_gitgraph#CheckGitAndRun() abort
    if !get(g:, 'rookie_auto_git_graph_enable', 0)
        return
    endif

    " Defer if in command-line mode ('c') or hit-enter prompt ('r')
    if mode() =~# '^[cr]'
        call timer_start(1000, {-> rookie_gitgraph#CheckGitAndRun()})
        return
    endif

    let l:current_state = rookie_gitgraph#GetGitState()
    " Only run if state is valid (in git) and has changed
    if !empty(l:current_state) && l:current_state != g:rookie_last_git_state
        let g:rookie_last_git_state = l:current_state
        " Use timer_start to avoid blocking and ensure UI is ready
        call timer_start(1000, {-> execute('RookieGitGraph')})
    endif
endfunction

" Initialize state on startup to avoid triggering immediately
let g:rookie_last_git_state = rookie_gitgraph#GetGitState()
