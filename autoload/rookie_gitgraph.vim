scriptencoding utf-8

function! s:UpdateGraphCallback(bufnr, cmd) abort
    if !bufexists(a:bufnr)
        return
    endif

    let l:output = systemlist(a:cmd)

    " Update buffer content
    call setbufvar(a:bufnr, '&modifiable', 1)
    call deletebufline(a:bufnr, 1, '$')
    call setbufline(a:bufnr, 1, l:output)

    " Apply highlighting and formatting
    let l:winid = bufwinid(a:bufnr)
    if l:winid != -1
        call win_execute(l:winid, 'silent! %s/^\([|\\/ ]*\)\*/\1●/e')
        call win_execute(l:winid, 'setlocal nomodifiable')
        call win_execute(l:winid, 'normal! gg')
        call win_execute(l:winid, 'call rookie_gitgraph#HighlightRefs()')
        call win_execute(l:winid, 'call search("HEAD ->")')
        call win_execute(l:winid, 'normal! zz')
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

    call setline(1, 'Fetching updates...')
    setlocal nomodifiable

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
    let l:cmd = 'git -C ' . shellescape(l:dir) . ' log --graph --decorate '
    if a:all_branches
        let l:cmd = l:cmd . '--all '
    endif
    let l:cmd = l:cmd . '--pretty=format:"%h [%ad] {%an} |%d %s" --date=format-local:"%y-%m-%d %H:%M"'

    " Async Fetch + Callback
    if get(g:, 'rookie_gitgraph_async_fetch', 1)
        call rookie_git#AsyncFetch(l:dir, function('s:UpdateGraphCallback', [l:bufnr, l:cmd]))
    else
        " Synchronous fallback
        if exists(':G')
            silent! execute 'G fetch'
        elseif exists(':Git')
            silent! execute 'Git fetch'
        else
            call system('git -C ' . shellescape(l:dir) . ' fetch --all --quiet')
        endif
        call s:UpdateGraphCallback(l:bufnr, l:cmd)
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

    highlight RookieGitGraphDecorRegion guifg=#7fbbb3 gui=bold cterm=bold
    highlight RookieGitGraphBracket guifg=#7fbbb3 gui=bold cterm=bold
    highlight RookieGitGraphOrigin guifg=orange gui=bold cterm=bold
    highlight RookieGitGraphHead guifg=red gui=bold cterm=bold
    highlight RookieGitGraphStarNormal guifg=#7fbbb3 gui=bold cterm=bold
    highlight RookieGitGraphStarOrigin guifg=orange gui=bold cterm=bold
    highlight RookieGitGraphStarHead   guifg=red     gui=bold cterm=bold

    execute 'syntax region RookieGitGraphDecorRegion matchgroup=RookieGitGraphBracket start=/\v\| *\(/ end=/\v\)\s/ keepend contains=RookieGitGraphOrigin,RookieGitGraphHead'
    execute 'syntax match RookieGitGraphOrigin /\vorigin\/[^, )]+/ contained containedin=RookieGitGraphDecorRegion'
    execute 'syntax match RookieGitGraphHead /\vHEAD(\s*->\s*[^,)]+)?/ contained containedin=RookieGitGraphDecorRegion'

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
