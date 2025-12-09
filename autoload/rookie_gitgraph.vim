scriptencoding utf-8

function! rookie_gitgraph#OpenGitGraph(all_branches) abort
    " If Fugitive is available, fetch updates before showing the graph
    if exists(':G')
        silent! execute 'G fetch'
    elseif exists(':Git')
        silent! execute 'Git fetch'
    endif
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

    if &filetype !=# 'git'
        vsplit
        wincmd l
        execute cmd
        wincmd k
        quit
    else
        execute cmd
    endif

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

    highlight RookieGitGraphDecorRegion guifg=#7fbbb3 gui=bold cterm=bold
    highlight RookieGitGraphBracket guifg=#7fbbb3 gui=bold cterm=bold
    highlight RookieGitGraphOrigin guifg=orange gui=bold cterm=bold
    highlight RookieGitGraphHead guifg=red gui=bold cterm=bold

    execute 'syntax region RookieGitGraphDecorRegion matchgroup=RookieGitGraphBracket start=/\v\| *\(/ end=/\v\)\s/ keepend contains=RookieGitGraphOrigin,RookieGitGraphHead'
    execute 'syntax match RookieGitGraphOrigin /\vorigin\/[^, )]+/ contained containedin=RookieGitGraphDecorRegion'
    execute 'syntax match RookieGitGraphHead /\vHEAD(\s*->\s*[^,)]+)?/ contained containedin=RookieGitGraphDecorRegion'
endfunction
