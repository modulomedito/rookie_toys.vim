scriptencoding utf-8

let g:rookie_git_fetch_timer = 0
let g:rookie_git_interval_watch_timer = 0
let g:rookie_git_fetch_last_interval = -1

function! rookie_git#AsyncFetch(...) abort
    let l:dir = getcwd()
    let l:Callback = v:null

    for l:Arg in a:000
        if type(l:Arg) == v:t_string
            let l:dir = l:Arg
        elseif type(l:Arg) == v:t_func
            let l:Callback = l:Arg
        endif
    endfor

    let l:cmd = ['git', '-C', l:dir, 'fetch', '--all', '--quiet']

    if exists('*jobstart')
        let l:opts = {'detach': v:true}
        if !empty(l:Callback)
            let l:opts.on_exit = {job_id, code, event -> l:Callback()}
        endif
        call jobstart(l:cmd, l:opts)
    elseif exists('*job_start')
        let l:opts = {
            \ 'in_io': 'null',
            \ 'out_io': 'null',
            \ 'err_io': 'null'
        \ }
        if !empty(l:Callback)
            let l:opts.exit_cb = {job, status -> l:Callback()}
        endif
        call job_start(l:cmd, l:opts)
    else
        if has('win32') || has('win64')
            if !empty(l:Callback)
                call system('git -C ' . shellescape(l:dir) . ' fetch --all --quiet')
                call l:Callback()
            else
                call system('cmd /c start "" /B git -C ' . shellescape(l:dir) . ' fetch --all --quiet')
            endif
        else
            if !empty(l:Callback)
                call system('git -C ' . l:dir . ' fetch --all --quiet')
                call l:Callback()
            else
                call system('sh -c ' . shellescape('git -C ' . l:dir . ' fetch --all --quiet >/dev/null 2>&1 &'))
            endif
        endif
    endif
endfunction

function! s:RookieGitDoFetch(timer) abort
    if get(g:, 'rookie_git_fetch_interval_s', 0) == 0
        if g:rookie_git_fetch_timer != 0
            call timer_stop(g:rookie_git_fetch_timer)
            let g:rookie_git_fetch_timer = 0
        endif
        return
    endif
    call rookie_git#AsyncFetch()
endfunction

function! rookie_git#AutoFetch() abort
    let interval = get(g:, 'rookie_git_fetch_interval_s', 0)
    if g:rookie_git_fetch_timer != 0
        call timer_stop(g:rookie_git_fetch_timer)
        let g:rookie_git_fetch_timer = 0
    endif
    if interval == 0
        let g:rookie_git_fetch_last_interval = interval
        return
    endif
    if !has('timers')
        return
    endif
    let g:rookie_git_fetch_timer = timer_start(interval * 1000, function('s:RookieGitDoFetch'), {'repeat': -1})
    let g:rookie_git_fetch_last_interval = interval
endfunction

function! s:RookieGitWatch(timer) abort
    let interval = get(g:, 'rookie_git_fetch_interval_s', 0)
    if interval != g:rookie_git_fetch_last_interval
        let g:rookie_git_fetch_last_interval = interval
        call rookie_git#AutoFetch()
    endif
endfunction

function! rookie_git#StartAutoFetchWatcher() abort
    if g:rookie_git_interval_watch_timer != 0
        call timer_stop(g:rookie_git_interval_watch_timer)
        let g:rookie_git_interval_watch_timer = 0
    endif
    if !has('timers')
        return
    endif
    let g:rookie_git_interval_watch_timer = timer_start(2000, function('s:RookieGitWatch'), {'repeat': -1})
endfunction

function! rookie_git#OpenCommitDiff(...) abort
    let l:commit = ''
    if a:0 > 0
        let l:commit = a:1
    else
        let l:line = getline('.')
        let l:match = matchstr(l:line, '\v<[0-9a-fA-F]{7,40}>')
        if !empty(l:match)
            let l:commit = l:match
        endif
    endif

    if empty(l:commit)
        echo "No commit hash found in line: " . getline('.')
        return
    endif

    let l:is_origin_gitgraph = (&filetype == 'git' && get(b:, 'is_rookie_gitgraph', 0))
    let l:origin_win = win_getid()

    let l:dir = getcwd()
    if exists('*FugitiveWorkTree')
        try
            let l:dir = FugitiveWorkTree()
        catch
        endtry
    endif

    let l:cmd = 'git -C ' . shellescape(l:dir) . ' diff-tree --no-commit-id --name-only -r ' . shellescape(l:commit)
    let l:files = systemlist(l:cmd)

    if v:shell_error
        echo "Error getting commit files: " . join(l:files, "\n")
        return
    endif

    if !exists('t:rookie_saved_ea')
        let t:rookie_saved_ea = &equalalways
        for w in range(1, winnr('$'))
            if getbufvar(winbufnr(w), 'is_rookie_gitgraph', 0)
                let t:rookie_saved_gg_winid = win_getid(w)
                let t:rookie_saved_gg_width = winwidth(w)
                break
            endif
        endfor
    endif

    set noequalalways

    let l:title = 'Diff: ' . l:commit
    let l:qf_list = []
    for l:file in l:files
        call add(l:qf_list, {'filename': l:file, 'text': 'Modified'})
    endfor

    call setqflist([], 'r', {'title': l:title, 'items': l:qf_list})

    let l:height = float2nr(&lines * 0.5)
    execute 'botright copen ' . l:height
    execute 'autocmd WinClosed <buffer> call rookie_git#OnWinClosed(expand("<amatch>"))'

    let b:rookie_diff_current_sha = l:commit
    let b:rookie_diff_target_sha = l:commit . '~1'
    nnoremap <buffer> <CR> :call rookie_git#ShowDiffFromQuickfix()<CR>

    normal! gg
    if !empty(l:qf_list)
        call rookie_git#ShowDiffFromQuickfix()
    endif

    if l:is_origin_gitgraph
        call win_gotoid(l:origin_win)
    endif
endfunction

function! rookie_git#ShowDiffFromQuickfix() abort
    let l:qf_idx = line('.') - 1
    let l:list = getqflist()
    if l:qf_idx < 0 || l:qf_idx >= len(l:list)
        return
    endif

    let l:item = l:list[l:qf_idx]
    let l:filename = bufname(l:item.bufnr)

    if empty(l:filename)
        return
    endif

    let l:git_filename = substitute(l:filename, '\\', '/', 'g')

    if !exists('b:rookie_diff_current_sha') || !exists('b:rookie_diff_target_sha')
        echoerr "SHA information missing in quickfix buffer."
        return
    endif

    let l:current_sha = b:rookie_diff_current_sha
    let l:target_sha = b:rookie_diff_target_sha

    if !exists('t:rookie_saved_ea')
        let t:rookie_saved_ea = &equalalways
        for w in range(1, winnr('$'))
            if getbufvar(winbufnr(w), 'is_rookie_gitgraph', 0)
                let t:rookie_saved_gg_winid = win_getid(w)
                let t:rookie_saved_gg_width = winwidth(w)
                break
            endif
        endfor
    endif

    set noequalalways

    let t:rookie_programmatic_close = 1
    if exists('t:rookie_diff_wins')
        for l:winid in t:rookie_diff_wins
            if win_id2win(l:winid) > 0
                execute win_id2win(l:winid) . 'close'
            endif
        endfor
    endif
    unlet t:rookie_programmatic_close
    let t:rookie_diff_wins = []
    let l:qf_winid = win_getid()

    vertical rightbelow new
    let l:win_target = win_getid()
    call add(t:rookie_diff_wins, l:win_target)
    execute 'autocmd WinClosed <buffer> call rookie_git#OnWinClosed(expand("<amatch>"))'

    let l:col_width = &columns / 3
    call win_execute(l:qf_winid, 'vertical resize ' . l:col_width)

    setlocal buftype=nofile bufhidden=wipe noswapfile
    let l:title_target = l:filename . ' (' . strpart(l:target_sha, 0, 7) . ')'
    silent! execute 'file ' . fnameescape(l:title_target)

    let l:check_cmd = 'git cat-file -e ' . shellescape(l:target_sha . ':' . l:git_filename)
    call system(l:check_cmd)

    if v:shell_error == 0
        let l:cmd = 'git show ' . shellescape(l:target_sha . ':' . l:git_filename)
        let l:content = systemlist(l:cmd)
        call setline(1, l:content)
    else
        call setline(1, ["File did not exist in " . l:target_sha])
    endif
    diffthis

    vertical rightbelow new
    let l:win_current = win_getid()
    call add(t:rookie_diff_wins, l:win_current)
    execute 'autocmd WinClosed <buffer> call rookie_git#OnWinClosed(expand("<amatch>"))'

    setlocal buftype=nofile bufhidden=wipe noswapfile
    let l:title_current = l:filename . ' (' . strpart(l:current_sha, 0, 7) . ')'
    silent! execute 'file ' . fnameescape(l:title_current)

    let l:check_cmd = 'git cat-file -e ' . shellescape(l:current_sha . ':' . l:git_filename)
    call system(l:check_cmd)

    if v:shell_error == 0
        let l:cmd = 'git show ' . shellescape(l:current_sha . ':' . l:git_filename)
        let l:content = systemlist(l:cmd)
        call setline(1, l:content)
    else
        call setline(1, ["File does not exist in " . l:current_sha])
    endif
    diffthis

    normal! gg
    call win_gotoid(l:win_target)
    normal! gg
endfunction

function! rookie_git#DiffFileNavigate(direction) abort
    let l:origin_win = win_getid()
    let l:qf_winid = 0

    for w in range(1, winnr('$'))
        if getwinvar(w, '&filetype') == 'qf' && getwinvar(w, 'quickfix_title') =~# '^Diff: '
            let l:qf_winid = win_getid(w)
            break
        endif
    endfor

    if l:qf_winid == 0
        echo "No Diff quickfix window found."
        return
    endif

    call win_gotoid(l:qf_winid)

    let l:cur_line = line('.')
    let l:last_line = line('$')

    if a:direction > 0
        if l:cur_line < l:last_line
            normal! j
        endif
    else
        if l:cur_line > 1
            normal! k
        endif
    endif

    call rookie_git#ShowDiffFromQuickfix()
    call win_gotoid(l:origin_win)
endfunction

function! rookie_git#OnWinClosed(winid) abort
    if exists('t:rookie_programmatic_close')
        return
    endif

    if exists('t:rookie_diff_wins')
        let l:idx = index(t:rookie_diff_wins, str2nr(a:winid))
        if l:idx >= 0
            call remove(t:rookie_diff_wins, l:idx)
        endif
    endif

    call timer_start(10, {-> s:CheckAndRestoreState()})
endfunction

function! s:CheckAndRestoreState() abort
    let l:has_diff = 0
    if exists('t:rookie_diff_wins')
        for l:winid in t:rookie_diff_wins
            if win_id2win(l:winid) > 0
                let l:has_diff = 1
                break
            endif
        endfor
    endif

    if !l:has_diff
        if exists('t:rookie_saved_ea')
            let &equalalways = t:rookie_saved_ea
            unlet t:rookie_saved_ea
        endif

        if exists('t:rookie_saved_gg_width') && exists('t:rookie_saved_gg_winid')
             let l:winid = t:rookie_saved_gg_winid
             let l:width = t:rookie_saved_gg_width
             if win_id2win(l:winid) > 0
                 call win_execute(l:winid, 'vertical resize ' . l:width)
             endif
             unlet t:rookie_saved_gg_width
             unlet t:rookie_saved_gg_winid
        endif
    endif
endfunction
