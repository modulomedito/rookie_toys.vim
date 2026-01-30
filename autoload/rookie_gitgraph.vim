scriptencoding utf-8

function! rookie_gitgraph#OpenGitGraph(all_branches) abort
    let cmd = 'Git log --graph --decorate '
    if a:all_branches
        let cmd = cmd . '--all '
    endif
    let cmd = cmd . '--pretty=format:"%h [%ad] {%an} |%d %s" --date=format-local:"%y-%m-%d %H:%M"'

    for b in getbufinfo({'bufloaded': 1})
        if getbufvar(b.bufnr, '&filetype') ==# 'git'
            execute 'bd ' . b.bufnr
        endif
    endfor

    vsplit
    wincmd l
    execute 'vertical resize ' . float2nr(&columns * 2.0 / 3.0)
    execute cmd
    setlocal modifiable
    silent! %s/^\([|\\/ ]*\)\*/\1●/e
    setlocal nomodifiable
    call cursor(1, 1)
    wincmd k
    quit

    call rookie_gitgraph#HighlightRefs()
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

