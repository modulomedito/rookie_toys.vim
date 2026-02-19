scriptencoding utf-8

let s:timer_id = -1
let s:scroll_ctx = {}
let s:duration = 0.3 " seconds
let s:interval = 10 " milliseconds

function! rookie_smooth#HalfPageDown() abort
    call s:StartScroll(1, 0.5)
endfunction

function! rookie_smooth#HalfPageUp() abort
    call s:StartScroll(-1, 0.5)
endfunction

function! rookie_smooth#PageDown() abort
    call s:StartScroll(1, 1.0)
endfunction

function! rookie_smooth#PageUp() abort
    call s:StartScroll(-1, 1.0)
endfunction

function! s:StartScroll(dir, scale) abort
    " Stop existing animation
    if s:timer_id != -1
        call timer_stop(s:timer_id)
        let s:timer_id = -1
    endif

    let l:view = winsaveview()
    let l:height = winheight(0)
    let l:dist = float2nr(l:height * a:scale)

    " Calculate targets
    " We want to maintain relative cursor position if possible
    let l:start_top = l:view.topline
    let l:start_lnum = l:view.lnum

    " Calculate target topline
    let l:target_top = l:start_top + (l:dist * a:dir)

    " Clamp target topline
    let l:last_line = line('$')
    if l:target_top < 1
        let l:target_top = 1
    endif
    if l:target_top > l:last_line
        let l:target_top = l:last_line
    endif

    " Calculate target lnum to maintain relative position
    " rel_pos = lnum - topline
    " new_lnum = new_topline + rel_pos
    let l:rel_pos = l:start_lnum - l:start_top
    let l:target_lnum = l:target_top + l:rel_pos

    " Special case for scrolling up when near the top
    if a:dir < 0 && l:target_top == 1
        " If we hit the top, ensure we can reach line 1
        if l:target_lnum > 1 && l:start_lnum > 1
             " If we are not at line 1, but target is still > 1, let's try to move further up if possible,
             " or just set target to 1 if the distance is small enough or simply to ensure we hit the top.
             " However, simply forcing it to 1 might be too aggressive if we are far away.
             " But user complained "cursor cannot go to the first line".
             " If topline is 1, and we scroll up, we probably want to reach line 1.
             let l:target_lnum = max([1, l:target_lnum - (l:dist/2)])
             if l:target_lnum < 1 | let l:target_lnum = 1 | endif
        endif
    endif

    " Clamp target lnum
    if l:target_lnum < 1
        let l:target_lnum = 1
    endif
    if l:target_lnum > l:last_line
        let l:target_lnum = l:last_line
    endif

    " Special case: if we are at the bottom/top and can't scroll more
    if l:start_top == l:target_top && l:start_lnum == l:target_lnum
        return
    endif

    let s:scroll_ctx = {
        \ 'start_top': l:start_top,
        \ 'start_lnum': l:start_lnum,
        \ 'target_top': l:target_top,
        \ 'target_lnum': l:target_lnum,
        \ 'start_time': reltime(),
        \ 'duration': s:duration
        \ }

    let s:timer_id = timer_start(s:interval, function('s:AnimateStep'), {'repeat': -1})
endfunction

function! s:AnimateStep(timer) abort
    let l:elapsed = reltimefloat(reltime(s:scroll_ctx.start_time))

    if l:elapsed >= s:scroll_ctx.duration
        " Finish
        call timer_stop(a:timer)
        let s:timer_id = -1
        call winrestview({'topline': float2nr(s:scroll_ctx.target_top), 'lnum': float2nr(s:scroll_ctx.target_lnum)})
        return
    endif

    " Ease out quad: t * (2 - t)
    let l:t = l:elapsed / s:scroll_ctx.duration
    let l:ease = l:t * (2.0 - l:t)

    let l:current_top = s:scroll_ctx.start_top + (s:scroll_ctx.target_top - s:scroll_ctx.start_top) * l:ease
    let l:current_lnum = s:scroll_ctx.start_lnum + (s:scroll_ctx.target_lnum - s:scroll_ctx.start_lnum) * l:ease

    call winrestview({'topline': float2nr(l:current_top), 'lnum': float2nr(l:current_lnum)})
    redraw
endfunction
