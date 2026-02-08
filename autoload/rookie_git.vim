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
                " Synchronous fallback if callback is required
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
    if &filetype != 'git'
        echoerr "RookieGitOpenCommitDiff is only available in git filetype buffers."
        return
    endif

    let l:line = getline('.')
    let l:current_sha = matchstr(l:line, '\v[0-9a-f]{7,40}')

    if empty(l:current_sha)
        echoerr "No git commit SHA found on current line."
        return
    endif

    let l:target_sha = ''
    if a:0 > 0
        let l:target_sha = a:1
    else
        let l:target_sha = l:current_sha . '~1'
    endif

    " Get changed files
    " We use git diff --name-only SHA1 SHA2
    let l:cmd = 'git diff --name-only ' . shellescape(l:target_sha) . ' ' . shellescape(l:current_sha)
    let l:output = system(l:cmd)

    if v:shell_error
        " If it failed (e.g. SHA^ not found), try to be helpful
        echom "Git diff failed (maybe parent commit doesn't exist?): " . substitute(l:output, '\n', ' ', 'g')
        return
    endif

    let l:files = split(l:output, "\n")
    if empty(l:files)
        echom "No files changed between " . l:target_sha . " and " . l:current_sha
        return
    endif

    let l:qf_list = []
    for l:file in l:files
        call add(l:qf_list, {'filename': l:file, 'text': 'Modified'})
    endfor

    call setqflist(l:qf_list)
    botright copen

    " Store SHAs for the quickfix buffer
    let b:rookie_diff_current_sha = l:current_sha
    let b:rookie_diff_target_sha = l:target_sha

    nnoremap <buffer> <CR> :call rookie_git#ShowDiffFromQuickfix()<CR>
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

    " Convert backslashes to forward slashes for git commands
    let l:git_filename = substitute(l:filename, '\\', '/', 'g')

    if !exists('b:rookie_diff_current_sha') || !exists('b:rookie_diff_target_sha')
        echoerr "SHA information missing in quickfix buffer."
        return
    endif

    let l:current_sha = b:rookie_diff_current_sha
    let l:target_sha = b:rookie_diff_target_sha

    " Close previous diff windows if they exist
    if exists('t:rookie_diff_wins')
        for l:winid in t:rookie_diff_wins
            if win_id2win(l:winid) > 0
                execute win_id2win(l:winid) . 'close'
            endif
        endfor
    endif
    let t:rookie_diff_wins = []

    " 1. Create split on the right of the current window (Quickfix)
    " We are in Quickfix, so 'vnew' will split it vertically.
    " However, user wants "right of the quickfix buffer".
    " If we are at the bottom, 'vertical rightbelow new' should do it.

    vertical rightbelow new
    let l:win_target = win_getid()
    call add(t:rookie_diff_wins, l:win_target)

    setlocal buftype=nofile bufhidden=wipe noswapfile

    let l:title_target = l:filename . ' (' . strpart(l:target_sha, 0, 7) . ')'
    silent! execute 'file ' . fnameescape(l:title_target)

    " Check if file exists in target commit
    " git cat-file -e SHA:FILE returns 0 if exists, 1 if not
    let l:check_cmd = 'git cat-file -e ' . shellescape(l:target_sha . ':' . l:git_filename)
    call system(l:check_cmd)

    if v:shell_error == 0
        let l:cmd = 'git show ' . shellescape(l:target_sha . ':' . l:git_filename)
        let l:content = systemlist(l:cmd)
        call setline(1, l:content)
    else
        " File doesn't exist in target commit (e.g. Added file)
        call setline(1, ["File did not exist in " . l:target_sha])
    endif
    diffthis

    " 2. Setup Right (Current)
    vertical rightbelow new
    let l:win_current = win_getid()
    call add(t:rookie_diff_wins, l:win_current)

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
        " File doesn't exist in current commit (e.g. Deleted file)
        call setline(1, ["File does not exist in " . l:current_sha])
    endif
    diffthis

    " Adjust cursor to start
    normal! gg
    call win_gotoid(l:win_target)
    normal! gg
endfunction
