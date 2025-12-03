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
    execute cmd
    " Highlight HEAD pointer for visibility
    silent! syntax match RookieGitGraphHead /HEAD ->\s\+[^,)]\+/ containedin=ALL
    silent! highlight RookieGitGraphHead cterm=bold ctermfg=red gui=bold guifg=Red
    " Highlight remote branch refs like origin/<branch> in orange
    silent! syntax match RookieGitGraphRemote /origin\/[^, )]\+/ containedin=ALL
    silent! highlight RookieGitGraphRemote cterm=bold ctermfg=214 gui=bold guifg=Orange
    " Highlight only the parentheses that wrap the decoration (%d)
    silent! syntax match RookieGitGraphDecorOpen /|\zs(/ containedin=ALL
    silent! syntax match RookieGitGraphDecorClose /)\ze\s/ containedin=ALL
    silent! highlight RookieGitGraphDecorOpen cterm=bold ctermfg=214 gui=bold guifg=Orange
    silent! highlight RookieGitGraphDecorClose cterm=bold ctermfg=214 gui=bold guifg=Orange
endfunction
