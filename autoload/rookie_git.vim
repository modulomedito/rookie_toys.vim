scriptencoding utf-8

let g:rookie_git_fetch_timer = 0
let g:rookie_git_interval_watch_timer = 0
let g:rookie_git_fetch_last_interval = -1

function! rookie_git#AsyncFetch(...) abort
    let l:dir = a:0 > 0 ? a:1 : getcwd()
    if exists('*jobstart')
        call jobstart(['git', '-C', l:dir, 'fetch', '--all', '--quiet'], {'detach': v:true})
    elseif exists('*job_start')
        call job_start(['git', '-C', l:dir, 'fetch', '--all', '--quiet'], {
            \ 'in_io': 'null',
            \ 'out_io': 'null',
            \ 'err_io': 'null'
        \ })
    else
        if has('win32') || has('win64')
            call system('cmd /c start "" /B git -C ' . shellescape(l:dir) . ' fetch --all --quiet')
        else
            call system('sh -c ' . shellescape('git -C ' . l:dir . ' fetch --all --quiet >/dev/null 2>&1 &'))
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
