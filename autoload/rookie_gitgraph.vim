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

    " Define a region for the refs decoration so matches are scoped
    silent! syntax region RookieGitGraphDecor start=/|\s\+(/ end=/)\s/ keepend
    " Highlight HEAD pointer for visibility
    silent! syntax match RookieGitGraphHead /HEAD ->\s\+[^,)]\+/ containedin=ALL
    silent! highlight RookieGitGraphHead cterm=bold ctermfg=red gui=bold guifg=Red
    " Highlight remote branch refs like origin/<branch> in orange
    silent! syntax match RookieGitGraphRemote /origin\/[^, )]\+/ containedin=ALL
    silent! highlight RookieGitGraphRemote cterm=bold ctermfg=214 gui=bold guifg=Orange
    " Allow whitespace between '|' and '(', as %d usually prints a leading space
    silent! syntax match RookieGitGraphDecorClose /)\ze\s/ containedin=ALL
    silent! highlight RookieGitGraphDecorClose cterm=bold ctermfg=214 gui=bold guifg=Orange
    " Highlight tag names after 'tag:' inside the decoration
    silent! syntax match RookieGitGraphTagName /tag:\s*\zs[^, )]\+/ contained containedin=RookieGitGraphDecor
    silent! highlight RookieGitGraphTagName cterm=bold ctermfg=79 gui=bold guifg=#7fbbb3
    " Highlight other local branch names inside the decoration (exclude HEAD, tag:, and origin/*)
    silent! syntax match RookieGitGraphOther /\v%(HEAD ->|tag:\s*|origin\/)@!\zs[^, )]+/ contained containedin=RookieGitGraphDecor
    silent! highlight RookieGitGraphOther cterm=bold ctermfg=79 gui=bold guifg=#7fbbb3
    " Fix highlight the opening parenthesis '(' in the decoration
    silent! syntax match RookieGitGraphDecorOpen /|\s\+\zs(/ containedin=ALL
    silent! highlight RookieGitGraphDecorOpen cterm=bold ctermfg=214 gui=bold guifg=Orange
endfunction
