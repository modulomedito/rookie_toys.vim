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
    " Scope decoration region: allow optional space after '|', and end at ')' before space or EOL
    silent! syntax region RookieGitGraphDecor start=/|\s*(/ end=/)\ze\(\s\|$\)/ keepend
    " Highlight HEAD pointer for visibility
    silent! syntax match RookieGitGraphHead /HEAD ->\s\+[^,)]\+/ containedin=ALL
    silent! highlight RookieGitGraphHead cterm=bold ctermfg=red gui=bold guifg=Red
    " Highlight remote branch refs like origin/<branch> in orange
    silent! syntax match RookieGitGraphRemote /origin\/[^, )]\+/ containedin=ALL
    silent! highlight RookieGitGraphRemote cterm=bold ctermfg=214 gui=bold guifg=Orange
    " Allow whitespace between '|' and '(', as %d usually prints a leading space
    silent! syntax match RookieGitGraphDecorOpen /|\s\+\zs(/ containedin=ALL
    silent! syntax match RookieGitGraphDecorClose /)\ze\s/ containedin=ALL
    silent! highlight RookieGitGraphDecorOpen cterm=bold ctermfg=214 gui=bold guifg=Orange
    silent! highlight RookieGitGraphDecorClose cterm=bold ctermfg=214 gui=bold guifg=Orange
    " Highlight tag names after 'tag:' inside the decoration
    silent! syntax match RookieGitGraphTagName /tag:\s*\zs[^, )]\+/ contained containedin=RookieGitGraphDecor
    silent! highlight RookieGitGraphTagName cterm=bold ctermfg=79 gui=bold guifg=#7fbbb3
    " Highlight other local branch names inside the decoration (exclude HEAD, tag:, and origin/*)
    " Anchor at '(' or ',' so we never start at the '|' character
    silent! syntax match RookieGitGraphOther /\v%(\(|,)\s*\zs%(HEAD ->|tag:\s*|origin\/)@![^, )]+/ contained containedin=RookieGitGraphDecor
    silent! highlight RookieGitGraphOther cterm=bold ctermfg=79 gui=bold guifg=#7fbbb3
endfunction
